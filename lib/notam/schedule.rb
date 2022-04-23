# frozen_string_literal: true

using AIXM::Refinements

module NOTAM

  # Structure to accommodate individual schedules used on D items
  class Schedule
    EVENTS = { 'SR' => :sunrise, 'SS' => :sunset }.freeze
    OPERATIONS = { 'PLUS' => 1, 'MINUS' => -1 }.freeze
    MONTHS = { 'JAN' => 1, 'FEB' => 2, 'MAR' => 3, 'APR' => 4, 'MAY' => 5, 'JUN' => 6, 'JUL' => 7, 'AUG' => 8, 'SEP' => 9, 'OCT' => 10, 'NOV' => 11, 'DEC' => 12 }.freeze
    DAYS = { 'MON' => :monday, 'TUE' => :tuesday, 'WED' => :wednesday, 'THU' => :thursday, 'FRI' => :friday, 'SAT' => :saturday, 'SUN' => :sunday, 'DAILY' => :any, 'DLY' => :any }.freeze

    H24_RE = /(?<h24>H24)/.freeze
    HOUR_RE = /(?<hour>[01]\d|2[0-4])(?<minute>[0-5]\d)/.freeze
    OPERATIONS_RE = /#{OPERATIONS.keys.join('|')}/.freeze
    EVENT_RE = /(?<event>SR|SS)(?:\s(?<operation>#{OPERATIONS_RE})(?<delta>\d+))?/.freeze
    TIME_RE = /#{HOUR_RE}|#{EVENT_RE}/.freeze
    TIME_RANGE_RE = /#{TIME_RE}-#{TIME_RE}|#{H24_RE}/.freeze
    DATE_RE = /[0-2]\d|3[01]/.freeze
    DAY_RE = /#{DAYS.keys.join('|')}/.freeze
    MONTH_RE = /#{MONTHS.keys.join('|')}/.freeze

    H24 = (AIXM.time('00:00')..AIXM.time('24:00')).freeze

    # Active dates or days
    #
    # @note If {#active} lists dates, then {#inactive} must list days and
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
    # @note If {#inactive} lists dates, then {#active} must list days and
    #   vice versa.
    #
    # @return [Array<NOTAM::Schedule::Dates>, Array<NOTAM::Schedule::Days>]
    attr_reader :inactives

    # @!visibility private
    def initialize(actives, times, inactives, base_date:)
      @actives, @times, @inactives = actives, times, inactives
      @base_date ||= base_date.at(day: 1)
    end

    class << self
      private :new

      # Parse the schedule part of a D item.
      #
      # @param string [String] raw schedule string
      # @param base_date [Date] month and year to assume when missing (day is
      #   force set to 1)
      def parse(string, base_date:)
        raw_actives, raw_times, raw_inactives = string.split(/((?: ?#{TIME_RANGE_RE.decapture})+)/).map(&:strip)
        raw_inactives = raw_inactives&.sub(/^EXC /, '')
        allocate.instance_eval do
          @base_date = base_date.at(day: 1)
          times = times_from(raw_times)
          if raw_actives.empty? || raw_actives.match?(DAY_RE)   # actives are days
            actives = days_from(raw_actives)
            inactives = raw_inactives ? dates_from(raw_inactives) : Dates.new
          else
            actives = dates_from(raw_actives)
            inactives = raw_inactives ? days_from(raw_inactives) : Days.new
          end
          initialize(actives, times, inactives, base_date: base_date)
          self
        end
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

    private

    # @return [Array<Date, Range<Date>>]
    def dates_from(string)
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
          base_date = base_date.at(month: MONTHS.fetch($~[:month]), wrap: true)
        else
          fail! "unrecognized date"
        end
        index += $&.length + 1
      end
      Dates.new(array)
    end

    # @return [Array<AIXM::Schedule::Day, Range<AIXM::Schedue::Day>>]
    def days_from(string)
      array = if string.empty?   # no declared day implies any day
        [AIXM.day(:any)]
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
      when H24_RE
        H24
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
    end

    class Dates < ScheduleArray
      # Convert subsequent entries to ranges
      #
      # @return [AIXM::Schedule::Dates]
      def cluster
        self.class.new(
          entries
            .slice_when { _1.succ != _2 }
            .map { _1.count > 1 ? (_1.first.._1.last) : _1.first }
        )
      end
    end

    class Days < ScheduleArray; end
    class Times < ScheduleArray; end
  end

end
