# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::Footer do
  subject do
    NOTAM::Factory.footer.transform_values do |value|
      NOTAM::Item.parse(value)
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

  describe :valid? do
    it "flags correct message as valid" do
      subject.each_value { _(_1).must_be :valid? }
    end

    it "flags incorrect message as invalid" do
      _(NOTAM::Item.parse('C) foobar')).wont_be :valid?
    end
  end
end
