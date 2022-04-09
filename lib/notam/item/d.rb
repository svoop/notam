# frozen_string_literal: true

module NOTAM

  # The D item contains timesheets to further narrow when exactly the NOTAM
  # is effective.
  class D < Item

    # Activity schedules
    #
    # @return [Array<NOTAM::Schedule>]
    attr_reader :schedules

    # @see NOTAM::Item#parse
    def parse
      base_date = AIXM.date(data[:effective_at])
      @schedules = cleanup(text).split(',').map do |string|
        Schedule.parse(string, base_date: base_date)
      end
      self
    end

    # Whether the D item is active at the given time.
    #
    # @param at [Time]
    # @return [Boolean]
    def active?(at:)
      schedules.any? { _1.active?(at: at, xy: data[:center_point]) }
    end

    def five_day_schedules
      schedules.map do |schedule|
        schedule
          .slice(AIXM.date(data[:effective_at]), AIXM.date(data[:effective_at] + 4 * 86_400))
          .resolve(on: data[:effective_at], xy: data[:center_point])
      end.map { _1 unless _1.empty? }.compact
    end

    # @see NOTAM::Item#merge
    def merge
      super(:schedules, :five_day_schedules)
    end

    private

    # @return [String]
    def cleanup(string)
      string
        .gsub(/\s+/, ' ')           # collapse whitespaces to single space
        .gsub(/ ?([-,]) ?/, '\1')   # remove spaces around dashes and commas
        .sub(/\AD\) /, '')          # remove item identifier
        .strip
    end

  end
end
