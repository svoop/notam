# frozen_string_literal: true

module NOTAM
  class B < Item

    RE = %r(
      \A
      B\)\s?
      (?<effective_at>#{TIME_RE})
      \z
    )x.freeze

    # @return [Time]
    def effective_at
      time(captures['effective_at'])
    end

    # @return [Boolean] +true+ if this message is valid
    def valid?
      super
    end

  end
end
