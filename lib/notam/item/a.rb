# frozen_string_literal: true

module NOTAM

  # The A item defines the locations (ICAO codes) affected by this NOTAM.
  class A < Item

    RE = %r(
      \A
      A\)\s?
      (?<locations>(?:#{ICAO_RE}\s?)+)
      \z
    )x.freeze

    # @return [Array<String>]
    def locations
      captures['locations'].split(/\s/)
    end

    # @see NOTAM::Item#merge
    def merge
      super(:locations)
    end

  end
end
