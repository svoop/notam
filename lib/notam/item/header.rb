# frozen_string_literal: true

using AIXM::Refinements

module NOTAM

  # The header item contains the NOTAM ID as well as information as to whether
  # its a new NOTAM or merely replacing or cancelling another one.
  class Header < Item

    RE = %r(
      \A
      (?<id>#{ID_RE})\s+
      NOTAM(?<operation>[NRC])\s*
      (?<old_id>#{ID_RE.decapture})?
      \z
    )x.freeze

    # @return [String] ID of this message
    def id
      captures['id']
    end

    # @return [String] series letter
    def id_series
      captures['id_series']
    end

    # @return [Integer] serial number
    def id_number
      captures['id_number'].to_i
    end

    # @return [Integer] year identifier
    def id_year
      captures['id_year'].to_i + (Date.today.year / 1000 * 1000)
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

    # @see NOTAM::Item#parse
    def parse
      super
      fail! "invalid operation" unless (new? && !captures['old_id']) || replaces || cancels
      self
    rescue
      fail! 'invalid Header item'
    end

    # @see NOTAM::Item#merge
    def merge
      super(:id, :id_series, :id_number, :id_year, :new?, :replaces, :cancels)
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} "#{truncated_text(start: 0)}">)
    end

  end
end
