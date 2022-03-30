# frozen_string_literal: true

require_relative '../../spec_helper'

describe NOTAM::Item do
  describe :item_class do
    it "detects header" do
      NOTAM::Factory.header.values.each do |subject|
        _(NOTAM::Item.item_class(subject)).must_equal 'Header'
      end
    end

    it "detects footer" do
      NOTAM::Factory.footer.values.each do |subject|
        _(NOTAM::Item.item_class(subject)).must_equal 'Footer'
      end
    end

    it "detects other items" do
      _(NOTAM::Item.item_class('A) test')).must_equal 'A'
      _(NOTAM::Item.item_class('G) test')).must_equal 'G'
      _(NOTAM::Item.item_class('Q) test')).must_equal 'Q'
    end

    it "returns nil for everything else" do
      _(NOTAM::Item.item_class('X) test')).must_be :nil?
      _(NOTAM::Item.item_class('a) test')).must_be :nil?
      _(NOTAM::Item.item_class('a] test')).must_be :nil?
      _(NOTAM::Item.item_class(' A) test')).must_be :nil?
      _(NOTAM::Item.item_class('test')).must_be :nil?
      _(NOTAM::Item.item_class('')).must_be :nil?
    end
  end
end
