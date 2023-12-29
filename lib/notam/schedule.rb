# frozen_string_literal: true

using AIXM::Refinements

module NOTAM

  # Structure to accommodate individual schedules used on D items
  class Schedule
    EVENTS = { 'SR' => :sunrise, 'SS' => :sunset }.freeze
    EVENT_HOURS = { sunrise: AIXM.time('06:00'), sunset: AIXM.time('18:00') }.freeze
    OPERATIONS = { 'PLUS' => 1, 'MINUS' => -1 }.freeze
    MONTHS = { 'JAN' => 1, 'FEB' => 2, 'MAR' => 3, 'APR' => 4, 'MAY' => 5, 'JUN' => 6, 'JUL' => 7, 'AUG' => 8, 'SEP' => 9, 'OCT' => 10, 'NOV' => 11, 'DEC' => 12 }.freeze
    DAYS = { 'MON' => :monday, 'TUE' => :tuesday, 'WED' => :wednesday, 'THU' => :thursday, 'FRI' => :friday, 'SAT' => :saturday, 'SUN' => :sunday, 'DAILY' => :any, 'DLY' => :any }.freeze

    DATE_RE = /[0-2]\d|3[01]/.freeze
    DAY_RE = /#{DAYS.keys.join('|')}/.freeze
    MONTH_RE = /#{MONTHS.keys.join('|')}/.freeze
    HCODE_RE = /(?<hcode>H24|HJ|HN)/.freeze
    HOUR_RE = /(?<hour>[01]\d|2[0-4])(?<minute>[0-5]\d)/.freeze
    OPERATIONS_RE = /#{OPERATIONS.keys.join('|')}/.freeze
    EVENT_RE = /(?<event>SR|SS)(?:\s(?<operation>#{OPERATIONS_RE})(?<delta>\d+))?/.freeze
    TIME_RE = /#{HOUR_RE}|#{EVENT_RE}/.freeze
    TIME_RANGE_RE = /#{TIME_RE}-#{TIME_RE}|#{HCODE_RE}/.freeze
    DATETIME_RE = /(?:(?<month>#{MONTH_RE}) )?(?<date>#{DATE_RE}) (?<time>#{TIME_RE})/.freeze
    DATETIME_RANGE_RE = /#{DATETIME_RE}-#{DATETIME_RE}/.freeze

    H24 = (AIXM::BEGINNING_OF_DAY..AIXM::END_OF_DAY).freeze
    HJ = (AIXM.time(:sunrise)..AIXM.time(:sunset)).freeze
    HN = (AIXM.time(:sunset)..AIXM.time(:sunrise)).freeze

    # Active dates or days
    #
    # @note If {#actives} lists dates, then {#inactives} must list days and
    #   vice versa.
    #
    # @return [Array<NOTAM::Schedule::Dates>, Array<NOTAM::Schedule::Days>]
    attr_reader :actives

    # Active times
    #
    # @return [Array<NOTAM::Schedule::Times>]
    attr_reader :times

    # Inactive dates or days
    #
    # @note If {#inactives} lists dates, then {#actives} must list days and
    #   vice versa.
    #
    # @return [Array<NOTAM::Schedule::Dates>, Array<NOTAM::Schedule::Days>]
    attr_reader :inactives

    # @!visibility private
    def initialize(actives, times, inactives, base_date:)
      @actives, @times, @inactives, @base_date = actives, times, inactives, base_date
    end

    class << self
      private :new

      # Parse the schedule part of a D item.
      #
      # @param string [String] raw schedule string
      # @param base_date [Date] month and year to assume when missing (day is
      #   force set to 1)
      # @return [Array<NOTAM::Schedule>] array of at least one schedule object
      def parse(string, base_date:)
        @rules, @exceptions = cleanup(string).split(/ EXC /).map(&:strip)
        @base_date = base_date.at(day: 1)
        case @rules
        when /^#{DATETIME_RANGE_RE}$/
          parse_datetimes
        when /^(#{DAY_RE}|#{TIME_RANGE_RE})/
          parse_days
        when /^(#{DATE_RE}|#{MONTH_RE})/
          parse_dates
        else
          fail! "unrecognized schedule"
        end
      end

      private

      def parse_datetimes
        from, to = @rules.split(/-/).map { datetime_from(_1) }
        delta = to.date - from.date
        fail! "invalid datetime" if delta < 1
        inactives = days_from(@exceptions)
        [
          new(Dates[from.date], Times[(from.time..AIXM::END_OF_DAY)], inactives, base_date: @base_date),
          (new(Dates[(from.date.next..to.date.prev)], Times[H24], inactives, base_date: @base_date) if delta > 1),
          new(Dates[to.date], Times[(AIXM::BEGINNING_OF_DAY..to.time)], inactives, base_date: @base_date)
        ].compact
      end

      %i(dates days).each do |active_unit|
        inactive_unit = active_unit == :days ? :dates : :days
        define_method("parse_#{active_unit}") do
          raw_active_unit, raw_times, unmatched = @rules.split(/((?: ?#{TIME_RANGE_RE.decapture})+)/, 3)
          fail! "unrecognized part after times" unless unmatched.empty?
          actives = send("#{active_unit}_from", raw_active_unit.strip)
          times = times_from(raw_times.strip)
          inactives = send("#{inactive_unit}_from", @exceptions)
          if times.any?(&method(:across_midnight?))
            times.each_with_object([]) do |time, array|
              if across_midnight? time
                array << new(actives, [(time.first..AIXM::END_OF_DAY)], inactives, base_date: @base_date)
                array << new(actives.next, [(AIXM::BEGINNING_OF_DAY..time.last)], inactives, base_date: @base_date)
              else
                array << new(actives, [time], inactives, base_date: @base_date)
              end
            end
          else
            [new(actives, times, inactives, base_date: @base_date)]
          end
        end
      end

      # @return [String]
      def cleanup(string)
        string
        .gsub(/\s+/, ' ')     # collapse whitespaces to single space
        .gsub(/ *- */, '-')   # remove spaces around dashes
        .strip
      end

      # @return [AIXM::Schedule::DateTime]
      def datetime_from(string)
        parts = string.match(DATETIME_RE).named_captures
        parts['year'] = @base_date.year
        parts['month'] = MONTHS[parts['month']] || @base_date.month
        AIXM.datetime(
          AIXM.date('%4d-%02d-%02d' % parts.slice('year', 'month', 'date').values.map(&:to_i)),
          AIXM.time(parts['time'])
        )
      end

      # @return [Array<Date, Range<Date>>]
      def dates_from(string)
        return Dates.new if string.nil?
        array, index, base_date = [], 0, @base_date.dup
        while index < string.length
          case string[index..]
          when /\A((?<from>#{DATE_RE})-(?:(?<month>#{MONTH_RE}) )?(?<to>#{DATE_RE}))/   # range of dates
            month = $~[:month] ? MONTHS.fetch($~[:month]) : base_date.month
            base_date = base_date.at(month: month, wrap: true).tap do |to_base_date|
              array << (base_date.at(day: $~[:from].to_i)..to_base_date.at(day: $~[:to].to_i))
            end
          when /\A(?<day>#{DATE_RE})/   # single date
            array << base_date.at(day: $~[:day].to_i)
          when /\A(?<month>#{MONTH_RE})/
            base_date = base_date.at(month: MONTHS.fetch($~[:month]), wrap: false)
          else
            fail! "unrecognized date"
          end
          index += $&.length + 1
        end
        Dates.new(array)
      end

      # @return [Array<AIXM::Schedule::Day, Range<AIXM::Schedule::Day>>]
      def days_from(string)
        return Days.new if string.nil?
        array = if string.empty?   # no declared day implies any day
          [AIXM::ANY_DAY]
        else
          string.split(' ').map do |token|
            from, to = token.split('-')
            if to   # range of days
              (AIXM.day(DAYS.fetch(from))..AIXM.day(DAYS.fetch(to)))
            else   # single day
              AIXM.day(DAYS.fetch(from))
            end
          end
        end
        Days.new(array)
      end

      # @return [Array<Range<AIXM::Schedule::Time>>]
      def times_from(string)
        array = string.split(/ (?!#{OPERATIONS_RE})/).map { time_range_from(_1) }
        Times.new(array)
      end

      # @return [Range<AIXM::Schedule::Time>]
      def time_range_from(string)
        case string
        when HCODE_RE
          const_get($~[:hcode].upcase)
        else
          from, to = string.split('-')
          (time_from(from)..time_from(to))
        end
      end

      # @return [AIXM::Schedule::Time]
      def time_from(string)
        case string
        when HOUR_RE
          hour, minute = $~[:hour], $~[:minute]
          AIXM.time([hour, minute].join(':'))
        when EVENT_RE
          event, operation, delta = $~[:event], $~[:operation], $~[:delta]&.to_i
          AIXM.time(EVENTS.fetch(event), plus: delta ? OPERATIONS.fetch(operation) * delta : 0)
        else
          fail! "unrecognized time"
        end
      end

      # @return [Boolean]
      def across_midnight?(time_range)
        from = time_range.first.time || EVENT_HOURS.fetch(time_range.first.event).time
        to = time_range.last.time || EVENT_HOURS.fetch(time_range.last.event).time
        from > to
      end
    end

    # @return [String]
    def inspect
      attr = %i(actives times inactives).map { "#{_1}: #{send(_1)}" }
      %Q(#<#{self.class} #{attr.join(', ')}>)
    end
    alias :to_s :inspect

    # Whether the schedule contains any actives
    #
    # @return [Boolean]
    def empty?
      actives.empty?
    end

    # Extract a sub-schedule for the given time window.
    #
    # @note {#inactives} of sub-schedules are always empty which guarantees
    #   they can be translated to AIXM or OFMX.
    #
    # @param from [AIXM::Schedule::Date] beginning date
    # @param to [AIXM::Schedule::Date] end date (defaults to +from+)
    # @return [NOTAM::Schedule]
    def slice(from, to=nil)
      sliced_actives = Dates.new
      (from..(to || from)).each do |date|
        sliced_actives << date if actives.cover?(date) && !inactives.cover?(date)
      end
      self.class.send(:new, sliced_actives.cluster, times, Days.new, base_date: @base_date)
    end

    # Resolve all events in {#times} for the given date and geographic location.
    #
    # @note The resolved times are rounded up (sunrise) or down (sunset) to the
    #   next 5 minutes.
    #
    # @see AIXM::Schedule::Time#resolve
    # @param on [AIXM::Date] date
    # @param xy [AIXM::XY] geographic location
    # @return [NOTAM::Schedule]
    def resolve(on:, xy:)
      resolved_times = times.map do |time|
        case time
        when Range
          (time.first.resolve(on: on, xy: xy, round: 5)..time.last.resolve(on: on, xy: xy, round: 5))
        else
          time.resolve(on: on, xy: xy, round: 5)
        end
      end
      self.class.send(:new, actives, Times.new(resolved_times), inactives, base_date: @base_date)
    end

    # Whether the schedule is active at the given time.
    #
    # @see AIXM::Schedule::Time#resolve
    # @param at [Time]
    # @param xy [AIXM::XY] geographic location
    # @return [NOTAM::Schedule]
    def active?(at:, xy:)
      date = AIXM.date(at)
      resolve(on: date, xy: xy).slice(date).times.cover? AIXM.time(at)
    end

    # Last +actives+ date of the schedule (+inatives+ are ignored).
    #
    # @return [AIXM::Date, nil] last date or +nil+ if schedule actives are days
    def last_date
      actives.last.then do |active|
        active = active.last if active.respond_to? :last
        active if active.instance_of? AIXM::Schedule::Date
      end
    end

    # @abstract
    class ScheduleArray < Array
      # @return [String]
      def inspect
        %Q(#<#{self.class} #{to_s}>)
      end

      # @return [String]
      def to_s
        '[' + entries.map { _1.to_s }.join(', ') + ']'
      end

      # Whether the given object is covered by this schedule array
      #
      # @param object [AIXM::Schedule::Date, AIXM::Schedule::Day,
      #   AIXM::Schedule::Time]
      # @return [Boolean]
      def cover?(object)
        any? { object.covered_by? _1 }
      end

      # Step through all elements and shift all dates or days to the next day
      #
      # @return [ScheduleArray]
      def next
        entries.map do |entry|
          if entry.instance_of? Range
            (entry.first.next..entry.last.next)
          else
            entry.next
          end
        end.then { self.class.new(_1) }
      end
    end

    class Dates < ScheduleArray
      # Convert subsequent entries to ranges
      #
      # @return [AIXM::Schedule::Dates]
      def cluster
        self.class.new(
          entries
            .slice_when { _1.next != _2 }
            .map { _1.count > 1 ? (_1.first.._1.last) : _1.first }
        )
      end
    end

    class Days < ScheduleArray; end
    class Times < ScheduleArray; end
  end

end
