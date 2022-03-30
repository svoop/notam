# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::Header do
  subject do
    NOTAM::Factory.header.transform_values do |value|
      NOTAM::Item.parse(value)
    end
  end

  describe :id do
    it "returns the message ID" do
      _(subject[:new].id).must_equal 'A0135/20'
    end
  end

  describe :new? do
    it "detects new message" do
      _(subject[:new]).must_be :new?
      _(subject[:replace]).wont_be :new?
      _(subject[:cancel]).wont_be :new?
    end
  end

  describe :replaces do
    it "detects replacing message and returns replaced message" do
      _(subject[:new].replaces).must_be :nil?
      _(subject[:replace].replaces).must_equal 'A0135/20'
      _(subject[:cancel].replaces).must_be :nil?
    end
  end

  describe :cancels do
    it "detects cancelling message and returns cancelled message" do
      _(subject[:new].cancels).must_be :nil?
      _(subject[:replace].cancels).must_be :nil?
      _(subject[:cancel].cancels).must_equal 'A0137/20'
    end
  end

  describe :valid? do
    it "flags correct message as valid" do
      subject.each_value { _(_1).must_be :valid? }
    end

    it "flags new message with old ID as invalid" do
      _(NOTAM::Item.parse('A0137/20 NOTAMN A0135/20')).wont_be :valid?
    end

    it "flags replacing/cancelling message without old ID as invalid" do
      _(NOTAM::Item.parse('A0137/20 NOTAMR')).wont_be :valid?
      _(NOTAM::Item.parse('A0137/20 NOTAMC')).wont_be :valid?
    end
  end
end
