# frozen_string_literal: true

module NOTAM
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

    # @return [Boolean] +true+ if this message is valid
    def valid?
      super
    end

  end
end
