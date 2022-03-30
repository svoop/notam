# frozen_string_literal: true

module NOTAM
  class E < Item

    RE = %r(
      \A
      E\)\s?
      (?<content>.+)
      \z
    )mx.freeze

    def content
      captures['content']
    end

    def translated_content
      content.split(/\b/).map do |word|
        (NOTAM::expand(word, translate: true) || word).upcase
      end.join
    end

    # @return [Boolean] +true+ if this message is valid
    def valid?
      super
    end

  end
end
