# frozen_string_literal: true

require_relative '../../../spec_helper'

describe NOTAM::D do
  context 'public' do
    let :data do
      {
        effective_at: Time.utc(2000, 2, 1, 6, 0),
        center_point: AIXM.xy(lat: 49.01614, long: 2.54423)
      }
    end

    describe :parse do
      it "must extract timesheet :two_months" do
        subject = NOTAM::Item.new(NOTAM::Factory.d[:two_months], data: data).parse
        _(subject.schedules.map(&:to_s)).must_equal([
          "#<NOTAM::Schedule actives: [2000-02-08..2000-02-28], times: [20:00 UTC..22:00 UTC], inactives: []>",
          "#<NOTAM::Schedule actives: [2000-03-01..2000-03-05], times: [18:00 UTC..22:00 UTC], inactives: []>"
        ])
      end

      it "must extract timesheet :one_month" do
        subject = NOTAM::Item.new(NOTAM::Factory.d[:one_month], data: data).parse
        _(subject.schedules.map(&:to_s)).must_equal([
          "#<NOTAM::Schedule actives: [2000-02-16, 2000-02-23], times: [00:00 UTC..24:00 UTC], inactives: []>",
          "#<NOTAM::Schedule actives: [2000-02-19, 2000-02-21..2000-02-24, 2000-02-28], times: [06:00 UTC..17:00 UTC], inactives: []>"
        ])
      end

      it "must extract timesheet :weekdays" do
        subject = NOTAM::Item.new(NOTAM::Factory.d[:weekdays], data: data).parse
        _(subject.schedules.map(&:to_s)).must_equal([
          "#<NOTAM::Schedule actives: [monday..friday], times: [07:00 UTC..11:00 UTC, 13:00 UTC..17:00 UTC], inactives: []>"
        ])
      end

      it "must extract timesheet :date_with_exception" do
        subject = NOTAM::Item.new(NOTAM::Factory.d[:date_with_exception], data: data).parse
        _(subject.schedules.map(&:to_s)).must_equal([
          "#<NOTAM::Schedule actives: [2000-02-01..2000-03-31], times: [07:00 UTC..11:00 UTC], inactives: [friday]>"
        ])
      end

      it "must extract timesheet :day_with_exception" do
        subject = NOTAM::Item.new(NOTAM::Factory.d[:day_with_exception], data: data).parse
        _(subject.schedules.map(&:to_s)).must_equal([
          "#<NOTAM::Schedule actives: [monday..tuesday], times: [07:00 UTC..19:00 UTC], inactives: [2000-02-15]>"
        ])
      end

      it "must extract timesheet :hours" do
        subject = NOTAM::Item.new(NOTAM::Factory.d[:hours], data: data).parse
        _(subject.schedules.map(&:to_s)).must_equal([
          "#<NOTAM::Schedule actives: [any], times: [22:00 UTC..05:00 UTC], inactives: []>"
        ])
      end

      it "must extract timesheet :daytime" do
        subject = NOTAM::Item.new(NOTAM::Factory.d[:daytime], data: data).parse
        _(subject.schedules.map(&:to_s)).must_equal([
          "#<NOTAM::Schedule actives: [any], times: [sunrise..sunset], inactives: []>"
        ])
      end

      it "must extract timesheet :sun_to_hour" do
        subject = NOTAM::Item.new(NOTAM::Factory.d[:sun_to_hour], data: data).parse
        _(subject.schedules.map(&:to_s)).must_equal([
          "#<NOTAM::Schedule actives: [any], times: [sunrise-30min..15:00 UTC], inactives: []>"
        ])
      end

      it "must extract timesheet :hour_to_sun" do
        subject = NOTAM::Item.new(NOTAM::Factory.d[:hour_to_sun], data: data).parse
        _(subject.schedules.map(&:to_s)).must_equal([
          "#<NOTAM::Schedule actives: [any], times: [10:00 UTC..sunset+30min], inactives: []>"
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

  context 'private' do
    subject do
      NOTAM::Item.new(NOTAM::Factory.d.values.first)
    end

    describe :cleanup do
      it "must collapse whitespaces to single space" do
        _(subject.send(:cleanup, "this\n\nis  a test")).must_equal 'this is a test'
      end

      it "must remove whitespaces around dashes" do
        _(subject.send(:cleanup, "10:00 -  11:00")).must_equal '10:00-11:00'
      end

      it "must remove whitespaces around commas" do
        _(subject.send(:cleanup, "one, two ,  three")).must_equal 'one,two,three'
      end

      it "must remove the D item identifier" do
        _(subject.send(:cleanup, "D) foobar")).must_equal 'foobar'
      end

      it "must remove heading and trailing whitespaces" do
        _(subject.send(:cleanup, " foobar \n\n")).must_equal 'foobar'
      end
    end

  end
end
