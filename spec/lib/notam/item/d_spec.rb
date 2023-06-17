# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::D do
  let :data do
    {
      effective_at: Time.utc(2000, 2, 1, 6, 0),
      center_point: AIXM.xy(lat: 49.01614, long: 2.54423)
    }
  end

  describe :parse do
    it "must extract timesheet :one_month" do
      subject = NOTAM::Item.new(NOTAM::Factory.d[:one_month], data: data).parse
      _(subject.schedules.map(&:to_s)).must_equal([
        "#<NOTAM::Schedule actives: [2000-02-16, 2000-02-23], times: [00:00 UTC..24:00 UTC], inactives: []>",
        "#<NOTAM::Schedule actives: [2000-02-19, 2000-02-21..2000-02-24, 2000-02-28], times: [06:00 UTC..17:00 UTC], inactives: []>"
      ])
    end

    it "must extract timesheet :two_months" do
      subject = NOTAM::Item.new(NOTAM::Factory.d[:two_months], data: data).parse
      _(subject.schedules.map(&:to_s)).must_equal([
        "#<NOTAM::Schedule actives: [2000-02-08..2000-02-28], times: [20:00 UTC..22:00 UTC], inactives: []>",
        "#<NOTAM::Schedule actives: [2000-03-01..2000-03-05], times: [18:00 UTC..22:00 UTC], inactives: []>"
      ])
    end

    it "must extract timesheet :simple_implicit_months" do
      subject = NOTAM::Item.new(NOTAM::Factory.d[:simple_implicit_months], data: data).parse
      _(subject.schedules.map(&:to_s)).must_equal([
        "#<NOTAM::Schedule actives: [2000-05-27], times: [05:30 UTC..10:00 UTC], inactives: []>",
        "#<NOTAM::Schedule actives: [2000-05-30], times: [08:00 UTC..21:00 UTC], inactives: []>",
        "#<NOTAM::Schedule actives: [2000-05-31], times: [05:30 UTC..21:00 UTC], inactives: []>",
        "#<NOTAM::Schedule actives: [2000-06-05], times: [08:00 UTC..21:59 UTC], inactives: []>",
        "#<NOTAM::Schedule actives: [2000-06-06..2000-06-08], times: [05:30 UTC..21:59 UTC], inactives: []>", "#<NOTAM::Schedule actives: [2000-06-09], times: [05:30 UTC..14:00 UTC], inactives: []>"
      ])
    end

    it "must extract timesheet :complex_implicit_months" do
      subject = NOTAM::Item.new(NOTAM::Factory.d[:complex_implicit_months], data: data).parse
      _(subject.schedules.map(&:to_s)).must_equal([
        "#<NOTAM::Schedule actives: [2000-06-13..2000-06-15, 2000-07-04..2000-07-06], times: [05:30 UTC..21:59 UTC], inactives: []>",
        "#<NOTAM::Schedule actives: [2000-07-08, 2000-07-10], times: [08:00 UTC..21:59 UTC], inactives: []>"
      ])
    end

    it "must extract timesheet :weekdays" do
      subject = NOTAM::Item.new(NOTAM::Factory.d[:weekdays], data: data).parse
      _(subject.schedules.map(&:to_s)).must_equal([
        "#<NOTAM::Schedule actives: [monday..friday], times: [07:00 UTC..11:00 UTC, 13:00 UTC..17:00 UTC], inactives: []>"
      ])
    end

    it "fails on invalid timesheet" do
      subject = NOTAM::Item.new(NOTAM::Factory.d[:invalid], data: data)
      error = _{ subject.parse }.must_raise NOTAM::ParseError
      _(error.item).must_be_instance_of NOTAM::D
      _(error.message).must_equal "invalid D item: D) 22 0700-1700 23 0430-1800 24 0430-1400"
    end
  end

  describe :active? do
    subject do
      NOTAM::Item.new(NOTAM::Factory.d[:daytime], data: data).parse
    end

    it "returns true if the given time is covered by acitve times" do
      _(subject.active?(at: Time.utc(2000, 2, 1, 12, 0))).must_equal true
    end

    it "returns false if the given time is not covered by acitve times" do
      _(subject.active?(at: Time.utc(2000, 2, 1, 1, 0))).must_equal false
    end
  end

  describe :five_day_schedules do
    subject do
      NOTAM::Item.new(NOTAM::Factory.d[:date_with_exception], data: data).parse
    end

    it "calculates five day schedules from effective date if it is in the future" do
      subject.stub(:five_day_base, Time.utc(2000, 1, 30)) do
        _(subject.five_day_schedules.to_s).must_equal "[#<NOTAM::Schedule actives: [2000-02-01..2000-02-03], times: [07:00 UTC..11:00 UTC], inactives: []>]"
      end
    end

    it "calculates five day schedule from now if effective date is in the past" do
      subject.stub(:five_day_base, Time.utc(2000, 3, 1)) do
        _(subject.five_day_schedules.to_s).must_equal "[#<NOTAM::Schedule actives: [2000-03-01..2000-03-02, 2000-03-04..2000-03-05], times: [07:00 UTC..11:00 UTC], inactives: []>]"
      end
    end
  end
end
