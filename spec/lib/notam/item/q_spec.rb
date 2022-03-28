require_relative '../../../spec_helper'

describe NOTAM::Q do
  subject do
    NOTAM::Factory.q.transform_values do |value|
      NOTAM::Item.parse(value)
    end
  end

  describe :fir do
    it "returns ICAO FIR" do
      _(subject[:egtt].fir).must_equal 'EGTT'
    end
  end

  describe :subject do
    it "returns subject as symbol" do
      _(subject[:egtt].subject).must_equal :runway
    end
  end

  describe :condition do
    it "returns condition as symbol" do
      _(subject[:egtt].condition).must_equal :other
    end
  end

  describe :traffic do
    it "returns traffic as symbol" do
      _(subject[:egtt].traffic).must_equal :ifr_and_vfr
    end
  end

  describe :purpose do
    it "returns purpose as array of symbols" do
      _(subject[:egtt].purpose).must_equal %i(immediate_attention operational_significance flight_operations)
    end
  end

  describe :scope do
    it "returns scope as array symbols" do
      _(subject[:egtt].scope).must_equal %i(aerodrome)
    end
  end

  describe :lower_limit do
    it "returns the lower limit as AIXM::Z" do
      _(subject[:egtt].lower_limit).must_equal AIXM::GROUND
    end
  end

  describe :upper_limit do
    it "returns the upper limit as AIXM::Z" do
      _(subject[:egtt].upper_limit).must_equal AIXM::UNLIMITED
    end
  end

  describe :valid? do
    it "flags correct message as valid" do
      subject.each_value { _(_1).must_be :valid? }
    end

    it "flags incorrect message as invalid" do
      _(NOTAM::Item.parse('Q) foobar')).wont_be :valid?
    end
  end
end
