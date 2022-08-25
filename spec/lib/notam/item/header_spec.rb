# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::Header do
  subject do
    NOTAM::Factory.header.transform_values do |value|
      NOTAM::Item.new(value).parse
    end
  end

  describe :id do
    it "returns the message ID" do
      _(subject[:new].id).must_equal 'A0135/20'
    end
  end

  describe :id_series do
    it "returns the series letter" do
      _(subject[:new].id_series).must_equal 'A'
    end
  end

  describe :id_number do
    it "returns the serial number" do
      _(subject[:new].id_number).must_equal 135
    end
  end

  describe :id_year do
    it "returns the year identifer" do
      _(subject[:new].id_year).must_equal 2020
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

  describe :parse do
    it "fails on incorrect message" do
      error = _{ NOTAM::Item.new('A0137/20 NOTAMN A0135/20').parse }.must_raise NOTAM::ParseError
      _(error.item).must_be_instance_of NOTAM::Header
      _(error.message).must_equal 'invalid Header item: A0137/20 NOTAMN A0135/20'
      _{ NOTAM::Item.new('A0137/20 NOTAMR').parse }.must_raise NOTAM::ParseError
      _{ NOTAM::Item.new('A0137/20 NOTAMC').parse }.must_raise NOTAM::ParseError
    end
  end
end
