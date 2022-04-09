# frozen_string_literal: true

module NOTAM

  # The E item contains a textual description of what this NOTAM is all about.
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

    # @see NOTAM::Item#merge
    def merge
      super(:content, :translated_content)
    end

  end
end
