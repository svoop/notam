# frozen_string_literal: true

module NOTAM

  # The G item defines the upper limit for this NOTAM.
  class G < Item

    RE = %r(
      \A
      G\)\s?
      (?<all>
        SFC|GND|UNL|
        (?<value>\d+)\s?(?<unit>FT|M)\s?(?<base>AMSL|AGL)|
        (?<unit>FL)\s?(?<value>\d+)
      )
      \z
    )x.freeze

    # @return [AIXM::Z]
    def upper_limit
      case captures['all']
        when 'UNL' then AIXM::UNLIMITED
        when 'SFC', 'GND' then AIXM::GROUND
        else limit(*captures.values_at('value', 'unit', 'base'))
      end
    end

    # @see NOTAM::Item#merge
    def merge
      super(:upper_limit)
    end

  end
end
