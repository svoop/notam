# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::F do
  subject do
    NOTAM::Factory.f.transform_values do |value|
      NOTAM::Item.new(value).parse
    end
  end

  describe :lower_limit do
    it "returns QNH value in FT" do
      _(subject[:qnh].lower_limit).must_equal AIXM.z(2000, :qnh)
    end

    it "returns QNH value converted from M to FT" do
      _(subject[:qnh_m].lower_limit).must_equal AIXM.z(3281, :qnh)
    end

    it "returns QFE value in FT" do
      _(subject[:qfe].lower_limit).must_equal AIXM.z(2100, :qfe)
    end

    it "returns QFE value converted from M to FT" do
      _(subject[:qfe_m].lower_limit).must_equal AIXM.z(3609, :qfe)
    end

    it "returns QNE value" do
      _(subject[:qne].lower_limit).must_equal AIXM.z(100, :qne)
      _(subject[:qne_space].lower_limit).must_equal AIXM.z(110, :qne)
    end

    it "returns AIXM::GROUND for SFC" do
      _(subject[:sfc].lower_limit).must_equal AIXM::GROUND
    end

    it "returns AIXM::GROUND for GND" do
      _(subject[:gnd].lower_limit).must_equal AIXM::GROUND
    end
  end
end
