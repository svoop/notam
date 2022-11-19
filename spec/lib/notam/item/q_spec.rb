# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::Q do
  subject do
    NOTAM::Factory.q.transform_values do |value|
      NOTAM::Item.new(value).parse
    end
  end

  describe :fir do
    it "returns ICAO FIR" do
      _(subject[:egtt].fir).must_equal 'EGTT'
    end
  end

  describe :subject_group do
    it "returns subject group as symbol" do
      _(subject[:egtt].subject_group).must_equal :movement_and_landing_area
    end
  end

  describe :subject do
    it "returns subject as symbol" do
      _(subject[:egtt].subject).must_equal :runway
    end
  end

  describe :condition_group do
    it "returns condition group as symbol" do
      _(subject[:egtt].condition_group).must_equal :limitations
    end
  end

  describe :condition do
    it "returns condition as symbol" do
      _(subject[:egtt].condition).must_equal :closed
    end
  end

  describe :traffic do
    it "returns traffic as symbol" do
      _(subject[:egtt].traffic).must_equal :ifr_and_vfr
    end

    it "strips spaces" do
      _(subject[:lfnt].traffic).must_equal :vfr
    end
  end

  describe :purpose do
    it "returns purpose as array of symbols" do
      _(subject[:egtt].purpose).must_equal %i(immediate_attention operational_significance flight_operations)
    end

    it "strips spaces" do
      _(subject[:lfnt].purpose).must_equal [:miscellaneous]
    end
  end

  describe :scope do
    it "returns scope as array symbols" do
      _(subject[:egtt].scope).must_equal %i(aerodrome en_route)
    end

    it "strips spaces" do
      _(subject[:lfnt].scope).must_equal [:aerodrome]
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

  describe :center_point do
    it "returns the center point as AIXM:XY" do
      _(subject[:egtt].center_point).must_equal AIXM.xy(lat: 51.48333333, long: -0.46666667)
    end
  end

  describe :radius do
    it "returns the radius as AIXM::D" do
      _(subject[:egtt].radius).must_equal AIXM.d(5, :nm)
    end
  end
end
