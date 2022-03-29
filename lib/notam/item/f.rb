# frozen_string_literal: true

module NOTAM
  class F < Item

    RE = %r(
      \A
      F\)\s?
      (?<all>
        UNL|
        (?<value>\d+)\s?(?<unit>FT|M)\s?(?<base>AMSL|AGL)|
        (?<unit>FL)\s?(?<value>\d+)
      )
      \z
    )x.freeze

    # @return [AIXM::Z]
    def upper_limit
      if captures['all'] == 'UNL'
        AIXM::UNLIMITED
      else
        limit(*captures.values_at('value', 'unit', 'base'))
      end
    end

    def valid?
      super
    end

  end
end
