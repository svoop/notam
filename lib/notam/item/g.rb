# frozen_string_literal: true

module NOTAM
  class G < Item

    RE = %r(
      \A
      G\)\s
      (?:
        (?<value>\d+)\s?(?<unit>FT|M)\s?(?<base>AMSL|AGL)|
        (?<unit>FL)\s?(?<value>\d+)
      )
      \z
    )x.freeze

    # @return [AIXM::Z]
    def lower_limit
      limit(*captures.values_at('value', 'unit', 'base'))
    end

    def valid?
      super
    end

  end
end
