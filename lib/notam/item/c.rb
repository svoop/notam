# frozen_string_literal: true

module NOTAM
  class C < Item

    RE = %r(
      \A
      C\)\s?
      (?<permanent>
        PERM|
        (?<expiration_at>#{TIME_RE}) \s? (?<estimated>EST)?
      )
      \z
    )x.freeze

    # @return [Time, nil]
    def expiration_at
      time(captures['expiration_at']) unless no_expiration?
    end

    # @return [Boolean]
    def estimated_expiration?
      !captures['estimated'].nil?
    end

    # @return [Boolean]
    def no_expiration?
      captures['permanent'] == 'PERM'
    end

    # @return [Boolean] +true+ if this message is valid
    def valid?
      super
    end

  end
end
