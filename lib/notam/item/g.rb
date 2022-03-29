# frozen_string_literal: true

module NOTAM
  class G < Item

    RE = %r(
      \A
      G\)\s?
      (?<all>
        SFC|
        GND|
        (?<value>\d+)\s?(?<unit>FT|M)\s?(?<base>AMSL|AGL)|
        (?<unit>FL)\s?(?<value>\d+)
      )
      \z
    )x.freeze

    # @return [AIXM::Z]
    def lower_limit
      if %w(SFC GND).include?(captures['all'])
        AIXM::GROUND
      else
        limit(*captures.values_at('value', 'unit', 'base'))
      end
    end

    def valid?
      super
    end

  end
end
