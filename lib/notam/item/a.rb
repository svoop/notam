# frozen_string_literal: true

module NOTAM

  # The A item defines the locations (ICAO codes) affected by this NOTAM.
  class A < Item

    RE = %r(
      \A
      A\)\s?
      (?<locations>(?:#{ICAO_RE}\s?)+)
      (?<parts>(?<part_index>\d+)\s+OF\s+(?<part_index_max>\d+))?
      \z
    )x.freeze

    # @return [Array<String>]
    def locations
      captures['locations'].split(/\s/)
    end

    # @return [Integer, nil]
    def part_index
      captures['parts'] ? captures['part_index'].to_i : 1
    end

    # @return [Integer, nil]
    def part_index_max
      captures['parts'] ? captures['part_index_max'].to_i : 1
    end

    # @see NOTAM::Item#merge
    def merge
      super(:locations, :part_index, :part_index_max)
    end

  end
end
