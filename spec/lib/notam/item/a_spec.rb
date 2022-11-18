# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::A do
  subject do
    NOTAM::Factory.a.transform_values do |value|
      NOTAM::Item.new(value).parse
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
end
