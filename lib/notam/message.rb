# frozen_string_literal: true

module NOTAM

  # NOTAM messages are plain text and consist of several ordered items:
  #
  #   WDDDD/DD ...   <- Header (mandatory)
  #   Q) ...         <- Q item: context (mandatory)
  #   A) ...         <- A item: locations (mandatory)
  #   B) ...         <- B item: effective from (mandatory)
  #   C) ...         <- C item: effective until (optional)
  #   D) ...         <- D item: timesheets (optional, may contain newlines)
  #   E) ...         <- E item: description (mandatory, may contain newlines)
  #   F) ...         <- F item: upper limit (optional)
  #   G) ...         <- G item: lower limit (optional)
  #   CREATED: ...   <- Footer (optional)
  #   SOURCE: ...    <- Footer (optional)
  #
  # Furthermore, oversized NOTAM may be split into several partial messages
  # which contain with +PART n OF n+ and +END PART n OF n+ markers. This is an
  # unofficial extension and therefore the markers may be found in different
  # places such as on the A item, on the E item or even somewhere in between.
  class Message

    UNSUPPORTED_FORMATS = %r(
      \A
      ![A-Z]{3,5} |                       # USA: NOTAM (D), FDC etc
      \w{3}\s\w{3}\s\([OU]\) |            # USA: (O) and (U) NOTAM
      \w{3}\s[A-Z]\d{4}/\d{2}\sMILITARY   # USA: military
    )xi.freeze

    PART_RE = %r(
      (?:END\s+)?PART\s+(?<part_index>\d+)\s+OF\s+(?<part_index_max>\d+)
    )xim.freeze

    FINGERPRINTS = %w[Q) A) B) C) D) E) F) G) CREATED: SOURCE:].freeze

    # Raw NOTAM text message
    #
    # @return [String]
    attr_reader :text

    # NOTAM item objects
    #
    # @return [Array<NOTAM::Item>]
    attr_reader :items

    # Parsed NOTAM message payload
    #
    # @return [Hash]
    attr_reader :data

    def initialize(text)
      fail(NOTAM::ParserError, "unsupported format") unless self.class.supported_format? text
      @text, @items, @data = text, [], {}
      itemize(departition(@text)).each do |raw_item|
        item = NOTAM::Item.new(raw_item, data: @data).parse.merge
        @items << item
      end
    end

    def inspect
      %Q(#<#{self.class} #{data[:id]}>)
    end
    alias :to_s :inspect

    # Whether the NOTAM is active at the given time.
    #
    # @param at [Time]
    # @return [Boolean]
    def active?(at:)
      (data[:effective_at]..data[:expiration_at]).include?(at) &&
        (!(d_item = item(:D)) || d_item.active?(at: at))
    end

    # Item of the given type
    #
    # @param type [Symbol, nil] either +:Header+, +:Q+, +(:A..:G)+ or +:Footer+
    def item(type)
      items.find { _1.type == type }
    end

    class << self
      undef_method :new

      # Parse the given raw NOTAM text message to create a new {NOTAM::Message}
      # object.
      #
      # @return [NOTAM::Message]
      def parse(text)
        allocate.instance_eval do
          initialize(text)
          self
        end
      end

      # Whether the given raw NOTAM text message is in a supported format.
      #
      # @return [Boolean]
      def supported_format?(text)
        !text.match? UNSUPPORTED_FORMATS
      end
    end

    private

    # @return [String]
    def departition(text)
      text.gsub(PART_RE, '').tap do
        if $~   # part marker found
          @data.merge!(
            part_index: $~[:part_index].to_i,
            part_index_max: $~[:part_index_max].to_i
          )
        end
      end
    end

    # @return [Array]
    def itemize(text)
      lines = text.gsub(/\s(#{NOTAM::Item::RE})/, "\n\\1").split("\n")
      last_index = -1
      [lines.first].tap do |array|
        lines[1..].each do |line|
          index = FINGERPRINTS.index(line.scan(/\A[A-Z]+?[):]/).first).to_i
          if index > last_index
            array << line
            last_index = index
          else
            array.push([array.pop, line].join("\n"))
          end
        end
      end
    end
  end

  # Shortcut of NOTAM::Message.parse
  #
  # @see NOTAM::Message.parse
  def self.parse(text)
    NOTAM::Message.parse(text)
  end
end
