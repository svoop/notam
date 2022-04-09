# frozen_string_literal: true

module NOTAM

  # The footer items contain meta information.
  class Footer < Item

    RE = %r(
      \A
      (?<key>CREATED|SOURCE):\s*
      (?<value>.+)
      \z
    )x.freeze

    # @return [String]
    def key
      captures['key'].downcase.to_sym
    end

    # @return [String, Time]
    def value
      case key
        when :created then Time.parse(captures['value'] + ' UTC')
        else captures['value']
      end
    end

    # @see NOTAM::Item#merge
    def merge
      data[key] = value
      self
    end

    # @return [String]
    def inspect
      %Q(#<#{self.class} "#{truncated_text(start: 0)}">)
    end

  end
end
