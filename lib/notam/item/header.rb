# frozen_string_literal: true

module NOTAM
  class Header < Item

    RE = %r(
      \A
      (?<id>#{ID_RE})\s+
      NOTAM(?<operation>[NRC])\s*
      (?<old_id>#{ID_RE})?
      \z
    )x.freeze

    # @return [String] ID of this message
    def id
      captures['id']
    end

    # @return [Boolean] +true+ if this is a new message, +false+ if it
    #   replaces or cancels another message
    def new?
      captures['operation'] == 'N'
    end

    # @return [String, nil] message being replaced by this message or +nil+
    #   if this message is a new or cancelling one
    def replaces
      captures['old_id'] if captures['operation'] == 'R'
    end

    # @return [String, nil] message being cancelled by this message or +nil+
    #   if this message is a new or replacing one
    def cancels
      captures['old_id'] if captures['operation'] == 'C'
    end

    # @return [Boolean] +true+ if this message is valid
    def valid?
      super && id && ((new? && !captures['old_id']) || replaces || cancels)
    end

    def inspect
      %Q(#<#{self.class} "#{truncated_content(start: 0)}">)
    end

  end
end
