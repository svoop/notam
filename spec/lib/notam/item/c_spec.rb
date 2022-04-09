# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::C do
  subject do
    NOTAM::Factory.c.transform_values do |value|
      NOTAM::Item.new(value).parse
    end
  end

  describe :expiration_at do
    it "returns expiration date and time of fix NOTAM" do
      _(subject[:fix].expiration_at).must_equal Time.parse('2002-10-31 02:00:00 UTC')
    end

    it "returns expiration date and time of estimated NOTAM" do
      _(subject[:estimated].expiration_at).must_equal Time.parse('2002-10-31 05:00:00 UTC')
      _(subject[:spaceless].expiration_at).must_equal Time.parse('2002-10-04 10:30:00 UTC')
    end

    it "returns nil for permanent NOTAM" do
      _(subject[:permanent].expiration_at).must_be :nil?
    end
  end

  describe :estimated_expiration? do
    it "detects fix NOTAM as non-estimated" do
      _(subject[:fix]).wont_be :estimated_expiration?
    end

    it "detects estimated NOTAM as estimated" do
      _(subject[:estimated]).must_be :estimated_expiration?
      _(subject[:spaceless]).must_be :estimated_expiration?
    end

    it "detects permanent NOTAM as non-estimated" do
      _(subject[:permanent]).wont_be :estimated_expiration?
    end
  end

  describe :no_expiration? do
    it "detects fix NOTAM as non-permanent" do
      _(subject[:fix]).wont_be :no_expiration?
    end

    it "detects estimated NOTAM non-permanent" do
      _(subject[:estimated]).wont_be :no_expiration?
      _(subject[:spaceless]).wont_be :no_expiration?
    end

    it "detects permanent NOTAM as permanent" do
      _(subject[:permanent]).must_be :no_expiration?
    end
  end
end
