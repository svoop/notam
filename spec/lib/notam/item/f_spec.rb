# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::F do
  subject do
    NOTAM::Factory.f.transform_values do |value|
      NOTAM::Item.parse(value)
    end
  end

  describe :upper_limit do
    it "returns QNH value in FT" do
      _(subject[:qnh].upper_limit).must_equal AIXM.z(2000, :qnh)
    end

    it "returns QNH value converted from M to FT" do
      _(subject[:qnh_m].upper_limit).must_equal AIXM.z(3281, :qnh)
    end

    it "returns QFE value in FT" do
      _(subject[:qfe].upper_limit).must_equal AIXM.z(2100, :qfe)
    end

    it "returns QFE value converted from M to FT" do
      _(subject[:qfe_m].upper_limit).must_equal AIXM.z(3609, :qfe)
    end

    it "returns QNE value" do
      _(subject[:qne].upper_limit).must_equal AIXM.z(100, :qne)
      _(subject[:qne_space].upper_limit).must_equal AIXM.z(110, :qne)
    end

    it "returns AIXM::UNLIMITED for UNL" do
      _(subject[:unl].upper_limit).must_equal AIXM::UNLIMITED
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
