# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::E do
  subject do
    NOTAM::Factory.e.transform_values do |value|
      NOTAM::Item.new(value).parse
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
end
