# frozen_string_literal: true

module NOTAM

  # Items are the building blocks of a NOTAM message. They usually consist of
  # only one line of plain text each, however, D and E items may span over
  # multiple lines of plain text.
  class Item

    RE = /[QA-G]\)\s/.freeze

    ID_RE = /(?<id_series>[A-Z])(?<id_number>\d{4})\/(?<id_year>\d{2})/.freeze
    ICAO_RE = /[A-Z]{4}/.freeze
    TIME_RE = /(?:\d{2})(?:0[1-9]|1[0-2])(?:0[1-9]|[12]\d|3[01])(?:[01]\d|[2][0-4])(?:[0-5]\d)/.freeze

    # Raw NOTAM item text
    #
    # @return [String]
    attr_reader :text

    # Captures from the default item regexp +RE+
    #
    # @return [MatchData]
    attr_reader :captures

    # Parsed NOTAM message payload
    #
    # @return [Hash]
    attr_reader :data

    # Analyses the raw NOTAM item text and initialize the corresponding item
    # object.
    #
    # @note Some NOTAM items (most notably {NOTAM::D}) depend on previous items
    #   for meaningful parsing and may fail if this information is not made
    #   available by passing the NOTAM message payload parsed so far as +data+.
    #
    # @example
    #   NOTAM::Item.new('A0135/20 NOTAMN')   # => #<NOTAM::Head id="A0135/20">
    #   NOTAM::Item.new('B) 0208231540')     # => #<NOTAM::B>
    #   NOTAM::Item.new('foobar')            # => NOTAM::ParseError
    #
    # @param text [String]
    # @param data [Hash]
    # @return [NOTAM::Header, NOTAM::Q, NOTAM::A, NOTAM::B, NOTAM::C,
    #   NOTAM::D, NOTAM::E, NOTAM::F, NOTAM::G, NOTAM::Footer]
    def initialize(text, data: {})
      @text, @data = text.strip, data
    end

    class << self
      # @!visibility private
      def new(text, data: {})
        NOTAM.const_get(type(text)).allocate.instance_eval do
          initialize(text, data: data)
          self
        end
      end

      # Analyses the raw NOTAM item text and detect its type.
      #
      # @example
      #   NOTAM::Item.type('A0135/20 NOTAMN')   # => :Header
      #   NOTAM::Item.type('B) 0208231540')     # => :B
      #   NOTAM::Item.type('SOURCE: LFNT')      # => :Footer
      #   NOTAM::Item.type('foobar')            # => NOTAM::ParseError
      #
      # @raise [NOTAM::ParseError]
      # @return [String]
      def type(text)
        case text.strip
          when /\A([A-GQ])\)/ then $1
          when NOTAM::Header::RE then 'Header'
          when NOTAM::Footer::RE then 'Footer'
          else fail(NOTAM::ParseError, 'item not recognized')
        end.to_sym
      end
    end

    # Matches the raw NOTAM item text against +RE+ and populates {#captures}.
    #
    # @note May be extended or overwritten in subclasses, but must always
    #   return +self+!
    #
    # @example
    #   NOTAM::Item.new('A0135/20 NOTAMN').parse   # => #<NOTAM::Header id="A0135/20">
    #   NOTAM::Item.new('foobar').parse            # => NOTAM::ParseError
    #
    # @abstract
    # @raise [NOTAM::ParseError]
    # @return [self]
    def parse
      if match_data = self.class::RE.match(text)
        begin
          @captures = match_data.named_captures
          self
        rescue
          fail! "invalid #{self.class.to_s.split('::').last} item"
        end
      else
        fail! 'text does not match regexp'
      end
    end

    # Merges the return values of the given methods into the +data+ hash.
    #
    # @note Must be extended in subclasses.
    #
    # @abstract
    # @params methods [Array<Symbol>]
    # @return [self]
    def merge(*methods)
      fail 'nothing to merge' unless methods.any?
      methods.each { @data[_1] = send(_1) }
      @data.compact!
      self
    end

    # Type of the item
    #
    # @return [Symbol] either +:Header+, +:Q+, +(:A..:G)+ or +:Footer+
    def type
      self.class.to_s[7..].to_sym
    end

    # Raise {NOTAM::ParseError} along with some debugging information.
    #
    # @param message [String] optional error message
    # @raise [NOTAM::ParseError]
    def fail!(message=nil)
      fail ParseError.new([message, text].compact.join(': '), item: self)
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} "#{truncated_text}">)
    end

    private

    def time(timestamp)
      short_year, month, day, hour, minute = timestamp.scan(/\d{2}/).map(&:to_i)
      millenium = Time.now.year / 100 * 100
      Time.utc(millenium + short_year, month, day, hour, minute)
    end

    def limit(value, unit, base)
      if captures['base']
        d = AIXM.d(value.to_i, unit).to_ft
        AIXM.z(d.dim.round, { 'AMSL' => :qnh, 'AGL' => :qfe }[base])
      else
        AIXM.z(value.to_i, :qne)
      end
    end

    def truncated_text(start: 3, length: 40)
      if text.length > start + length - 1
        text[start, length - 1] + '…'
      else
        text[start..]
      end
    end

  end
end
