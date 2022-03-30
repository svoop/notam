# frozen_string_literal: true

module NOTAM
  class Q < Item

    RE = %r(
      \A
      Q\)\s?
      (?<fir>#{ICAO_RE})/
      Q(?<subject>[A-Z]{2})(?<condition>[A-Z]{2})/
      (?<traffic>I|V|IV)/
      (?<purpose>NBO|BO|M|K)/
      (?<scope>A|AE|AW|E|W|K)/
      (?<lower_limit>\d{3})/
      (?<upper_limit>\d{3})/
      (?<latitude>\d{4}[NS])(?<longitude>\d{5}[EW])(?<radius>\d{3})
      \z
    )x.freeze

    # @return [String]
    def fir
      captures['fir']
    end

    # @return [Symbol]
    def subject
      NOTAM.subject_for(captures['subject'])
    end

    # @return [Symbol]
    def condition
      NOTAM.condition_for(captures['condition'])
    end

    # @return [Symbol]
    def traffic
      NOTAM.traffic_for(captures['traffic'])
    end

    # @return [Array<Symbol>]
    def purpose
      captures['purpose'].chars.map { NOTAM.purpose_for(_1) }
    end

    # @return [Array<Symbol>]
    def scope
      captures['scope'].chars.map { NOTAM.scope_for(_1) }
    end

    # @return [AIXM::Z] lower limit (QNE flight level) or {AIXM::GROUND}
    #   (aka: 0ft QFE)
    def lower_limit
      if (limit = captures['lower_limit'].to_i).zero?
        AIXM::GROUND
      else
        AIXM.z(captures['lower_limit'].to_i, :qne)
      end
    end

    # @return [AIXM::Z] upper limit (QNE  flight level) or {AIXM::UNLIMITED}
    #   (aka: FL999 QNE)
    def upper_limit
      AIXM.z(captures['upper_limit'].to_i, :qne)
    end

    # @return [Boolean] +true+ if this message is valid
    def valid?
      super
    end

  end
end
