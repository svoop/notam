# frozen_string_literal: true

module NOTAM
  class Item

    ID_RE = /[A-RU-Z]\d{4}\/\d{2}/.freeze
    FIR_RE = /[A-Z]{4}/.freeze

    attr_reader :content

    class << self
      undef_method :new

      # Parse NOTAM content and initialize the corresponding item
      #
      # @example
      #   NOTAM::Item.parse('A0135/20 NOTAMN')   # => #<NOTAM::Head id="A0135/20">
      #   NOTAM::Item.parse('B) 0208231540')     # => #<NOTAM::B>
      #   NOTAM::Item.parse('foobar')            # => ArgumentError
      #
      # @return [NOTAM::Item] parsed item
      def parse(content)
        NOTAM.const_get(item_class(content)).allocate.instance_eval do
          @content = content
          self
        end
      end

      # Detect the item class
      #
      # @example
      #   NOTAM::Item.parse('A0135/20 NOTAMN')   # => "Head"
      #   NOTAM::Item.parse('B) 0208231540')     # => "B"
      #   NOTAM::Item.parse('foobar')            # => ArgumentError
      #
      # @return [String] item class
      def item_class(content)
        case content
          when /\A([A-GQ])\)/ then $1
          when NOTAM::Head::RE then 'Head'
          else fail(ArgumentError, 'format not recognized')
        end
      end
    end

    def inspect
      %Q(#<#{self.class} "#{truncated_content}">)
    end

    private

    def valid?
      !!captures
    end

    def captures
      @captures ||= self.class.const_get('RE').match(@content)&.named_captures
    end

    def truncated_content(start: 3, length: 40)
      content.length > length + start ? content[start, length-1] + '…' : content
    end

  end
end
