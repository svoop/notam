# frozen_string_literal: true

module NOTAM

  # The B item defines when the NOTAM goes into effect.
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

    # @see NOTAM::Item#merge
    def merge
      super(:effective_at)
    end

  end
end
