# frozen_string_literal: true

module NOTAM
  class A < Item

    RE = %r(
      \A
      A\)\s
      (?<locations>(?:#{ICAO_RE}\s?)+)
      \z
    )x.freeze

    # @return [Array<String>]
    def locations
      captures['locations'].split(/\s/)
    end

    def valid?
      super
    end

  end
end
