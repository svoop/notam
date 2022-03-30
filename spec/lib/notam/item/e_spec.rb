# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::E do
  subject do
    NOTAM::Factory.e.transform_values do |value|
      puts value
      NOTAM::Item.parse(value)
    end
  end

  describe :content do
    it "returns raw content string" do
      _(subject[:rwy].content).must_equal 'RWY 09R/27L DUE WIP NO CENTRELINE, TDZ OR SALS LIGHTING AVBL'
    end
  end

  describe :translated_content do
    it "translates contractions" do
      _(subject[:rwy].translated_content).must_equal 'RUNWAY 09R/27L DUE WORK IN PROGRESS NO CENTRELINE, TOUCHDOWN ZONE OR SALS LIGHTING AVAILABLE'
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
