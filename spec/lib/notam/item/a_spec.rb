require_relative '../../../spec_helper'

describe NOTAM::A do
  subject do
    NOTAM::Factory.a.transform_values do |value|
      NOTAM::Item.parse(value)
    end
  end

  describe :locations do
    it "returns array of one location" do
      _(subject[:egll].locations).must_equal %w(EGLL)
    end

    it "returns array of multiple locations" do
      _(subject[:lsas].locations).must_equal %w(LSAS LOVV LIMM)
    end
  end

  describe :valid? do
    it "flags correct message as valid" do
      subject.each_value { _(_1).must_be :valid? }
    end

    it "flags incorrect message as invalid" do
      _(NOTAM::Item.parse('A) foobar')).wont_be :valid?
    end
  end
end
