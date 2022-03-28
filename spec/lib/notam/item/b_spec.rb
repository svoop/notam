require_relative '../../../spec_helper'

describe NOTAM::B do
  subject do
    NOTAM::Factory.b.transform_values do |value|
      NOTAM::Item.parse(value)
    end
  end

  describe :effective_at do
    it "returns date and time when NOTAM becomes effective" do
      _(subject[:fix].effective_at).must_equal Time.parse('2002-08-23 15:40:00 UTC')
    end
  end

  describe :valid? do
    it "flags correct message as valid" do
      subject.each_value { _(_1).must_be :valid? }
    end

    it "flags incorrect message as invalid" do
      _(NOTAM::Item.parse('B) foobar')).wont_be :valid?
    end
  end
end
