# frozen_string_literal: true

require_relative '../../spec_helper'

describe NOTAM::Item do
  describe :'.type' do
    it "detects header" do
      NOTAM::Factory.header.values.each do |subject|
        _(NOTAM::Item.type(subject)).must_equal :Header
      end
    end

    it "detects footer" do
      NOTAM::Factory.footer.values.each do |subject|
        _(NOTAM::Item.type(subject)).must_equal :Footer
      end
    end

    it "detects other items" do
      _(NOTAM::Item.type('A) test')).must_equal :A
      _(NOTAM::Item.type('G) test')).must_equal :G
      _(NOTAM::Item.type('Q) test')).must_equal :Q
    end

    it "strips text" do
      _(NOTAM::Item.type('  A) test  ')).must_equal :A
    end

    it "fails for everything else" do
      _{ NOTAM::Item.type('X) test') }.must_raise NOTAM::ParseError
      _{ NOTAM::Item.type('a) test') }.must_raise NOTAM::ParseError
      _{ NOTAM::Item.type('a] test') }.must_raise NOTAM::ParseError
      _{ NOTAM::Item.type('test') }.must_raise NOTAM::ParseError
      _{ NOTAM::Item.type('') }.must_raise NOTAM::ParseError
    end
  end

  describe :initialize do
    it "strips text" do
      _(NOTAM::Item.new('  A) test  ').text).must_equal 'A) test'
    end
  end

  describe :parse do
    it "fails on incorrect message" do
      _{ NOTAM::Item.new('A) foobar').parse }.must_raise NOTAM::ParseError
    end
  end

  describe :type do
    it "returns the type" do
      _(NOTAM::Item.new('E) foobar').parse.type).must_equal :E
    end
  end

  describe :text do
    it "exposes the raw NOTAM text" do
      subject = NOTAM::Factory.q.fetch(:egtt)
      _(NOTAM::Item.new(subject).parse.text).must_equal subject
    end
  end
end
