# frozen_string_literal: true

module NOTAM
  class ParseError < StandardError
    attr_reader :item

    def initialize(message, item: nil)
      @item = item
      super(message)
    end
  end
end
