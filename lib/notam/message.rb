# frozen_string_literal: true

module NOTAM

  # NOTAM messages are plain text and consist of several ordered items:
  #
  #   WDDDD/DD ...   <- Header line (mandatory)
  #   Q) ...         <- Q line: context (mandatory)
  #   A) ...         <- A line: locations (mandatory)
  #   B) ...         <- B line: effective from (mandatory)
  #   C) ...         <- C line: effective until (optional)
  #   D) ...         <- D line: timesheets (optional, may contain newlines)
  #   E) ...         <- E line: description (mandatory, may contain newlines)
  #   F) ...         <- F line: upper limit (optional)
  #   G) ...         <- G line: lower limit (optional)
  #   CREATED: ...   <- Footer (optional)
  #   SOURCE: ...    <- Footer (optional)
  class Message

    UNSUPPORTED_FORMATS = %r(
      \A
      ![A-Z]{3,5} |                       # USA: NOTAM (D), FDC etc
      \w{3}\s\w{3}\s\([OU]\) |            # USA: (O) and (U) NOTAM
      \w{3}\s[A-Z]\d{4}/\d{2}\sMILITARY   # USA: military
    )xi.freeze

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
      itemize(text).each do |raw_item|
        item = NOTAM::Item.new(raw_item, data: @data).parse.merge
        @items << item
        @data = item.data
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
