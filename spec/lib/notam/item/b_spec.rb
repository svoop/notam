# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::B do
  subject do
    NOTAM::Factory.b.transform_values do |value|
      NOTAM::Item.new(value).parse
    end
  end

  describe :effective_at do
    it "returns date and time when NOTAM becomes effective" do
      _(subject[:fix].effective_at).must_equal Time.parse('2002-08-23 15:40:00 UTC')
    end
  end
end
