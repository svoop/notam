# frozen_string_literal: true

require_relative '../../spec_helper'

describe NOTAM::Item do
  describe :item_class do
    it "detects head" do
      NOTAM::Factory.head.values.each do |subject|
        _(NOTAM::Item.item_class(subject)).must_equal 'Head'
      end
    end

    it "detects other items" do
      _(NOTAM::Item.item_class('A) test')).must_equal 'A'
      _(NOTAM::Item.item_class('G) test')).must_equal 'G'
      _(NOTAM::Item.item_class('Q) test')).must_equal 'Q'
    end

    it "fails for everything else" do
      _{ NOTAM::Item.item_class('X) test') }.must_raise ArgumentError
      _{ NOTAM::Item.item_class('a) test') }.must_raise ArgumentError
      _{ NOTAM::Item.item_class('a] test') }.must_raise ArgumentError
      _{ NOTAM::Item.item_class(' A) test') }.must_raise ArgumentError
      _{ NOTAM::Item.item_class('test') }.must_raise ArgumentError
      _{ NOTAM::Item.item_class('') }.must_raise ArgumentError
    end
  end
end
