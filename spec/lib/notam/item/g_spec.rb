# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::G do
  subject do
    NOTAM::Factory.g.transform_values do |value|
      NOTAM::Item.parse(value)
    end
  end

  describe :lower_limit do
    it "returns QNH value in FT" do
      _(subject[:qnh].lower_limit).must_equal AIXM.z(2050, :qnh)
    end

    it "returns QNH value converted from M to FT" do
      _(subject[:qnh_m].lower_limit).must_equal AIXM.z(3445, :qnh)
    end

    it "returns QFE value in FT" do
      _(subject[:qfe].lower_limit).must_equal AIXM.z(2150, :qfe)
    end

    it "returns QFE value converted from M to FT" do
      _(subject[:qfe_m].lower_limit).must_equal AIXM.z(3773, :qfe)
    end

    it "returns QNE value" do
      _(subject[:qne].lower_limit).must_equal AIXM.z(150, :qne)
      _(subject[:qne_space].lower_limit).must_equal AIXM.z(160, :qne)
    end

    it "returns AIXM::GROUND for SFC" do
      _(subject[:sfc].lower_limit).must_equal AIXM::GROUND
    end

    it "returns AIXM::GROUND for GND" do
      _(subject[:gnd].lower_limit).must_equal AIXM::GROUND
    end
  end

  describe :valid? do
    it "flags correct message as valid" do
      subject.each_value { _(_1).must_be :valid? }
    end

    it "flags incorrect message as invalid" do
      _(NOTAM::Item.parse('C) foobar')).wont_be :valid?
    end
  end
end
