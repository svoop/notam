# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::Footer do
  subject do
    NOTAM::Factory.footer.transform_values do |value|
      NOTAM::Item.new(value).parse
    end
  end

  describe :key do
    it "returns downcased key as Symbol" do
      _(subject[:created].key).must_equal :created
      _(subject[:source].key).must_equal :source
    end
  end

  describe :value do
    it "returns Time for CREATED key" do
      _(subject[:created].value).must_equal Time.parse('2022-02-10 07:00:00 UTC')
    end

    it "returns plain text for other keys" do
      _(subject[:source].value).must_equal 'LSSNYNYX'
    end
  end
end
