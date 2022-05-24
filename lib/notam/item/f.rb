# frozen_string_literal: true

module NOTAM

  # The F item defines the lower limit for this NOTAM.
  class F < Item

    RE = %r(
      \A
      F\)\s?
      (?<all>
        SFC|GND|UNL|
        (?<value>\d+)\s?(?<unit>FT|M)\s?(?<base>AMSL|AGL)|
        (?<unit>FL)\s?(?<value>\d+)
      )
      \z
    )x.freeze

    # @return [AIXM::Z]
    def lower_limit
      case captures['all']
        when 'UNL' then AIXM::UNLIMITED
        when 'SFC', 'GND' then AIXM::GROUND
        else limit(*captures.values_at('value', 'unit', 'base'))
      end
    end

    # @see NOTAM::Item#merge
    def merge
      super(:lower_limit)
    end

  end
end
