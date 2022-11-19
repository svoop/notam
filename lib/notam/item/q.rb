# frozen_string_literal: true

module NOTAM

  # The Q item provides the context such as the FIR or conditions.
  class Q < Item

    RE = %r(
      \A
      Q\)\s?
      (?<fir>#{ICAO_RE})/
      Q(?<subject>[A-Z]{2})(?<condition>[A-Z]{2})/
      (?<traffic>IV|(?:[IVK]\s?))/
      (?<purpose>NBO|BO\s?|(?:[BMK]\s{0,2}))/
      (?<scope>A[EW]|(?:[AEWK]\s?))/
      (?<lower_limit>\d{3})/
      (?<upper_limit>\d{3})/
      (?<lat_deg>\d{2})(?<lat_min>\d{2})(?<lat_dir>[NS])
      (?<long_deg>\d{3})(?<long_min>\d{2})(?<long_dir>[EW])
      (?<radius>\d{3})
      \z
    )x.freeze

    # @return [String]
    def fir
      captures['fir']
    end

    # @return [Symbol]
    def subject_group
      NOTAM.subject_group_for(captures['subject'][0,1])
    end

    # @return [Symbol]
    def subject
      NOTAM.subject_for(captures['subject'])
    end

    # @return [Symbol]
    def condition_group
      NOTAM.condition_group_for(captures['condition'][0,1])
    end

    # @return [Symbol]
    def condition
      NOTAM.condition_for(captures['condition'])
    end

    # @return [Symbol]
    def traffic
      NOTAM.traffic_for(captures['traffic'].strip)
    end

    # @return [Array<Symbol>]
    def purpose
      captures['purpose'].strip.chars.map { NOTAM.purpose_for(_1) }
    end

    # @return [Array<Symbol>]
    def scope
      captures['scope'].strip.chars.map { NOTAM.scope_for(_1) }
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

    # @return [AIXM::XY] approximately affected area center point
    def center_point
      AIXM.xy(
        lat: %Q(#{captures['lat_deg']}°#{captures['lat_min']}'00"#{captures['lat_dir']}),
        long: %Q(#{captures['long_deg']}°#{captures['long_min']}'00"#{captures['long_dir']})
      )
    end

    # @return [AIXM::D] approximately affected area radius
    def radius
      AIXM.d(captures['radius'].to_i, :nm)
    end

    # @see NOTAM::Item#merge
    def merge
      super(:fir, :subject_group, :subject, :condition_group, :condition, :traffic, :purpose, :scope, :lower_limit, :upper_limit, :center_point, :radius)
    end

  end
end
