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

  describe :part_index do
    it "detects multipart NOTAM index" do
      _(subject[:checklist].part_index).must_equal 1
    end

    it "returns 1 for non-multipart NOTAM" do
      _(subject[:egll].part_index).must_equal 1
    end
  end

  describe :part_index_max do
    it "detects multipart NOTAM max index" do
      _(subject[:checklist].part_index_max).must_equal 5
    end

    it "returns 1 for non-multipart NOTAM" do
      _(subject[:egll].part_index_max).must_equal 1
    end
  end
end
