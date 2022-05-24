# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::G do
  subject do
    NOTAM::Factory.g.transform_values do |value|
      NOTAM::Item.new(value).parse
    end
  end

  describe :upper_limit do
    it "returns QNH value in FT" do
      _(subject[:qnh].upper_limit).must_equal AIXM.z(2050, :qnh)
    end

    it "returns QNH value converted from M to FT" do
      _(subject[:qnh_m].upper_limit).must_equal AIXM.z(3445, :qnh)
    end

    it "returns QFE value in FT" do
      _(subject[:qfe].upper_limit).must_equal AIXM.z(2150, :qfe)
    end

    it "returns QFE value converted from M to FT" do
      _(subject[:qfe_m].upper_limit).must_equal AIXM.z(3773, :qfe)
    end

    it "returns QNE value" do
      _(subject[:qne].upper_limit).must_equal AIXM.z(150, :qne)
      _(subject[:qne_space].upper_limit).must_equal AIXM.z(160, :qne)
    end

    it "returns AIXM::UNLIMITED for UNL" do
      _(subject[:unl].upper_limit).must_equal AIXM::UNLIMITED
    end
  end
end
