# frozen_string_literal: true

require_relative '../../spec_helper'

describe NOTAM::Schedule do
  context 'public' do
    describe :parse do
      let :base_date do
        AIXM.date('2000-02-01')
      end

      it "must extract schedule :date" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:date], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-02-05')]
          _(subject.times).must_equal [(AIXM.time('11:30')..AIXM.time('13:30'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :dates" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:dates], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-02-05'), AIXM.date('2000-02-09'), AIXM.date('2000-02-13')]
          _(subject.times).must_equal [(AIXM.time('11:30')..AIXM.time('13:30'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :dates_with_month" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:dates_with_month], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-02-05'), AIXM.date('2000-03-06')]
          _(subject.times).must_equal [(AIXM.time('11:00')..AIXM.time('12:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :date_range" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:date_range], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [(AIXM.date('2000-02-05')..AIXM.date('2000-02-18'))]
          _(subject.times).must_equal [(AIXM.time('11:30')..AIXM.time('13:30'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :date_range_with_exception" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:date_range_with_exception], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [(AIXM.date('2000-02-05')..AIXM.date('2000-02-18'))]
          _(subject.times).must_equal [(AIXM.time('11:30')..AIXM.time('13:30'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_equal [AIXM.day(:friday)]
        end
      end

      it "must extract schedule :date_across_midnight" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:date_across_midnight], base_date: base_date)
        _(schedules.count).must_equal 2
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-02-08'), AIXM.date('2000-02-29')]
          _(subject.times).must_equal [(AIXM.time('21:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
        schedules[1].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-02-09'), AIXM.date('2000-03-01')]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('06:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :date_range_with_month" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:date_range_with_month], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [(AIXM.date('2000-02-01')..AIXM.date('2000-03-31'))]
          _(subject.times).must_equal [(AIXM.time('07:00')..AIXM.time('11:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :date_range_across_end_of_year" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:date_range_across_end_of_year], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [(AIXM.date('2000-12-30')..AIXM.date('2001-01-02'))]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :day" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:day], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:monday)]
          _(subject.times).must_equal [(AIXM.time('07:00')..AIXM.time('19:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :days" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:days], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:monday), AIXM.day(:wednesday), AIXM.day(:friday)]
          _(subject.times).must_equal [(AIXM.time('07:00')..AIXM.time('19:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :day_range" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:day_range], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [(AIXM.day(:monday)..AIXM.day(:tuesday))]
          _(subject.times).must_equal [(AIXM.time('07:00')..AIXM.time('19:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :day_range_with_exception" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:day_range_with_exception], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [(AIXM.day(:monday)..AIXM.day(:tuesday))]
          _(subject.times).must_equal [(AIXM.time('07:00')..AIXM.time('19:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_equal [AIXM.date('2000-02-15')]
        end
      end

      it "must extract schedule :day_across_midnight" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:day_across_midnight], base_date: base_date)
        _(schedules.count).must_equal 2
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:monday)]
          _(subject.times).must_equal [(AIXM.time('22:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
        schedules[1].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:tuesday)]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('04:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :datetime" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:datetime], base_date: base_date)
        _(schedules.count).must_equal 3
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-02-08')]
          _(subject.times).must_equal [(AIXM.time('08:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
        schedules[1].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [(AIXM.date('2000-02-09')..AIXM.date('2000-02-11'))]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
        schedules[2].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-02-12')]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('20:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :datetime_with_exception" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:datetime_with_exception], base_date: base_date)
        _(schedules.count).must_equal 3
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-02-08')]
          _(subject.times).must_equal [(AIXM.time('08:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_equal [AIXM.day(:friday)]
        end
        schedules[1].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [(AIXM.date('2000-02-09')..AIXM.date('2000-02-11'))]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_equal [AIXM.day(:friday)]
        end
        schedules[2].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-02-12')]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('20:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_equal [AIXM.day(:friday)]
        end
      end

      it "must extract schedule :datetime_with_month" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:datetime_with_month], base_date: base_date)
        _(schedules.count).must_equal 3
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-02-08')]
          _(subject.times).must_equal [(AIXM.time('08:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
        schedules[1].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [(AIXM.date('2000-02-09')..AIXM.date('2000-03-11'))]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
        schedules[2].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-03-12')]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('20:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :datetime_across_midnight" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:datetime_across_midnight], base_date: base_date)
        _(schedules.count).must_equal 2
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-05-29')]
          _(subject.times).must_equal [(AIXM.time('22:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
        schedules[1].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.actives).must_equal [AIXM.date('2000-05-30')]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('22:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :multiple_times" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:multiple_times], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [(AIXM.day(:monday)..AIXM.day(:friday))]
          _(subject.times).must_equal [(AIXM.time('07:00')..AIXM.time('11:00')), (AIXM.time('13:00')..AIXM.time('17:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :multiple_times_across_midnight" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:multiple_times_across_midnight], base_date: base_date)
        _(schedules.count).must_equal 3
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:monday)]
          _(subject.times).must_equal [(AIXM.time('07:00')..AIXM.time('11:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
        schedules[1].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:monday)]
          _(subject.times).must_equal [(AIXM.time('23:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
        schedules[2].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:tuesday)]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('02:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :daily" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:daily], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:any)]
          _(subject.times).must_equal [(AIXM.time('10:00')..AIXM.time('20:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :daily_across_midnight" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:daily_across_midnight], base_date: base_date)
        _(schedules.count).must_equal 2
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:any)]
          _(subject.times).must_equal [(AIXM.time('22:00')..AIXM.time('24:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
        schedules[1].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:any)]
          _(subject.times).must_equal [(AIXM.time('00:00')..AIXM.time('05:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :daytime" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:daytime], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:any)]
          _(subject.times).must_equal [(AIXM.time(:sunrise)..AIXM.time(:sunset))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :sun_to_hour" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:sun_to_hour], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:any)]
          _(subject.times).must_equal [(AIXM.time(:sunrise, minus: 30)..AIXM.time('15:00'))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
      end

      it "must extract schedule :hour_to_sun" do
        schedules = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:hour_to_sun], base_date: base_date)
        _(schedules.count).must_equal 1
        schedules[0].then do |subject|
          _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
          _(subject.actives).must_equal [AIXM.day(:any)]
          _(subject.times).must_equal [(AIXM.time('10:00')..AIXM.time(:sunset, plus: 30))]
          _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
          _(subject.inactives).must_be :empty?
        end
      end
    end

    describe :empty? do
      subject do
        NOTAM::Schedule.send(:new,
          NOTAM::Schedule::Dates.new,
          NOTAM::Schedule::Times.new,
          NOTAM::Schedule::Days.new,
          base_date: AIXM.date('2000-01-01')
        )
      end

      it "returns true if no actives are present" do
        _(subject).must_be :empty?
      end

      it "returns false if actives are present" do
        _(subject.tap { _1.actives << AIXM.date('2000-02-02') }).wont_be :empty?
      end
    end

    describe :slice do
      it "consolidates :date_range_with_exception" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:date_range_with_exception], base_date: AIXM.date('2000-02-02'))
        _(subject.count).must_equal 1
        _(subject[0].slice(AIXM.date('2000-02-09'), AIXM.date('2000-02-12')).to_s).must_equal(
          "#<NOTAM::Schedule actives: [2000-02-09..2000-02-10, 2000-02-12], times: [11:30 UTC..13:30 UTC], inactives: []>"
        )
      end

      it "consolidates :day_range_with_exception" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:day_range_with_exception], base_date: AIXM.date('2000-01-01'))
        _(subject.count).must_equal 1
        _(subject[0].slice(AIXM.date('2000-02-14'), AIXM.date('2000-02-27')).to_s).must_equal(
          "#<NOTAM::Schedule actives: [2000-02-14, 2000-02-21..2000-02-22], times: [07:00 UTC..19:00 UTC], inactives: []>"
        )
      end

      it "consolidates :datetime_with_exception" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:datetime_with_exception], base_date: AIXM.date('2000-02-01'))
        _(subject.count).must_equal 3
        _(subject[1].slice(AIXM.date('2000-02-09'), AIXM.date('2000-02-10')).to_s).must_equal(
          "#<NOTAM::Schedule actives: [2000-02-09..2000-02-10], times: [00:00 UTC..24:00 UTC], inactives: []>"
        )
      end

      it "defaults to a time frame of one day" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:daytime], base_date: AIXM.date('2000-01-01'))
        _(subject.count).must_equal 1
        _(subject[0].slice(AIXM.date('2000-02-02')).to_s).must_equal(
          "#<NOTAM::Schedule actives: [2000-02-02], times: [sunrise..sunset], inactives: []>"
        )
      end

      it "accepts custom time frames" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:daytime], base_date: AIXM.date('2000-01-01'))
        _(subject.count).must_equal 1
        _(subject[0].slice(AIXM.date('2000-02-02'), AIXM.date('2000-02-03')).to_s).must_equal(
          "#<NOTAM::Schedule actives: [2000-02-02..2000-02-03], times: [sunrise..sunset], inactives: []>"
        )
      end
    end

    # See https://aiphub.tower.zone/LF/AIP/GEN-2.7 for official sunrise and sunset
    # tables in UTC. The coordinates are LFPG on latitude 49°N. You have to
    # subtract 10 minutes to compensate for longitude 2.5°E. The result is
    # rounded up (sunrise) or down (sunset) to the next 5 minutes.
    describe :resolve do
      subject do
        NOTAM::Schedule.parse(NOTAM::Factory.schedule[:daytime], base_date: AIXM.date('2025-01-01')).first.slice(AIXM.date('2025-07-01'))
      end

      it "resolves sunrise and sunset to clock times" do
        resolved = subject.resolve(
          on: AIXM.date('2025-07-01'),
          xy: AIXM.xy(lat: 49.01614, long: 2.54423)
        )
        _(resolved.times).must_equal [AIXM.time('03:50')..AIXM.time('19:55')]
        _(resolved.actives).must_equal subject.actives
        _(resolved.inactives).must_equal subject.inactives
      end
    end

    describe :active? do
      subject do
        NOTAM::Schedule.parse(NOTAM::Factory.schedule[:daytime], base_date: AIXM.date('2000-01-01'))
      end

      it "returns true if the given time is covered by active times" do
        _(subject.count).must_equal 1
        _(subject.first.active?(at: Time.utc(2000, 1, 1, 12, 0), xy: AIXM.xy(lat: 49.01614, long: 2.54423))).must_equal true
      end

      it "returns false if the given time is not covered by active times" do
        _(subject.count).must_equal 1
        _(subject.first.active?(at: Time.utc(2000, 1, 1, 1, 0), xy: AIXM.xy(lat: 49.01614, long: 2.54423))).must_equal false
      end
    end

    describe :last_date do
      it "returns the last actives date if dates are used" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:dates_with_month], base_date: AIXM.date('2000-01-01'))
        _(subject.first.last_date).must_equal AIXM.date('2000-03-06')
      end

      it "returns nil if days are used" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:days], base_date: AIXM.date('2000-01-01'))
        _(subject.first.last_date).must_be :nil?
      end
    end
  end

  context 'private' do
    subject do
      NOTAM::Schedule
    end

    describe :cleanup do
      it "must collapse whitespaces to single space" do
        _(subject.send(:cleanup, "this\n\nis  a test")).must_equal 'this is a test'
      end

      it "must remove spaces around dashes" do
        _(subject.send(:cleanup, "0100-0200, 0300 -0400, 0500 - 0600, 0700-  0800")).must_equal '0100-0200, 0300-0400, 0500-0600, 0700-0800'
      end

      it "must remove heading and trailing whitespaces" do
        _(subject.send(:cleanup, " foobar \n\n")).must_equal 'foobar'
      end
    end

    describe :dates_from do
      it "recognizes nil" do
        _(subject.send(:dates_from, nil)).must_equal([])
      end

      it "recognizes implicit month" do
        subject.instance_eval { @base_date = AIXM.date('2000-03-01') }
        _(subject.send(:dates_from, '01 19 26-28')).must_equal([
          AIXM.date('2000-03-01'),
          AIXM.date('2000-03-19'),
          (AIXM.date('2000-03-26')..AIXM.date('2000-03-28'))
        ])
      end

      it "recognizes mix of implicit and explicit months" do
        subject.instance_eval { @base_date = AIXM.date('2000-04-01') }
        _(subject.send(:dates_from, '05 MAY 19')).must_equal([
          AIXM.date('2000-04-05'),
          AIXM.date('2000-05-19')
        ])
      end

      it "recognizes one explicit month" do
        subject.instance_eval { @base_date = AIXM.date('2000-01-01') }
        _(subject.send(:dates_from, 'MAY 12 18-20')).must_equal([
          AIXM.date('2000-05-12'),
          (AIXM.date('2000-05-18')..AIXM.date('2000-05-20'))
        ])
      end

      it "recognizes multiple explicit months" do
        subject.instance_eval { @base_date = AIXM.date('2000-01-01') }
        _(subject.send(:dates_from, 'APR 04-05 MAY 18')).must_equal([
          (AIXM.date('2000-04-04')..AIXM.date('2000-04-05')),
          AIXM.date('2000-05-18')
        ])
      end

      it "recognizes ranges from implicit to explicit months" do
        subject.instance_eval { @base_date = AIXM.date('2000-02-01') }
        _(subject.send(:dates_from, '27-MAR 02 06-APR 10')).must_equal([
          (AIXM.date('2000-02-27')..AIXM.date('2000-03-02')),
          (AIXM.date('2000-03-06')..AIXM.date('2000-04-10'))
        ])
      end

      it "recognizes ranges from explicit to implicit months" do
        subject.instance_eval { @base_date = AIXM.date('2000-01-01') }
        _(subject.send(:dates_from, 'APR 11-13 MAY 01-05')).must_equal([
          (AIXM.date('2000-04-11')..AIXM.date('2000-04-13')),
          (AIXM.date('2000-05-01')..AIXM.date('2000-05-05'))
        ])
      end

      it "recognizes ranges from explicit to explicit months" do
        subject.instance_eval { @base_date = AIXM.date('2000-03-01') }
        _(subject.send(:dates_from, 'APR 10-MAY 11 JUN 04-JUL 07')).must_equal([
          (AIXM.date('2000-04-10')..AIXM.date('2000-05-11')),
          (AIXM.date('2000-06-04')..AIXM.date('2000-07-07'))
        ])
      end
    end

    describe :days_from do
      it "recognizes nil" do
        _(subject.send(:days_from, nil)).must_equal([])
      end

      it "recognizes single weekdays and ranges of weekdays" do
        _(subject.send(:days_from, 'MON WED-FRI SUN')).must_equal([
          AIXM.day(:monday),
          (AIXM.day(:wednesday)..AIXM.day(:friday)),
          AIXM.day(:sunday)
        ])
      end

      it "recognizes daily" do
        _(subject.send(:days_from, 'DAILY')).must_equal([AIXM.day(:any)])
        _(subject.send(:days_from, 'DLY')).must_equal([AIXM.day(:any)])
      end
    end

    describe :times_from do
      it "must extract array of time ranges" do
        _(subject.send(:times_from, '0900-1100 1300-SS')).must_equal [(AIXM.time('09:00')..AIXM.time('11:00')), (AIXM.time('13:00')..AIXM.time(:sunset))]
      end
    end

    describe :time_range_from do
      it "must extract time range" do
        _(subject.send(:time_range_from, '0900-SS')).must_equal (AIXM.time('09:00')..AIXM.time(:sunset))
      end
    end

    describe :time_from do
      it "must extract time" do
        _(subject.send(:time_from, '2212')).must_equal AIXM.time('22:12')
      end

      it "must extract event" do
        _(subject.send(:time_from, 'SR')).must_equal AIXM.time(:sunrise)
        _(subject.send(:time_from, 'SR PLUS15')).must_equal AIXM.time(:sunrise, plus: 15)
        _(subject.send(:time_from, 'SS MINUS25')).must_equal AIXM.time(:sunset, minus: 25)
      end
    end

    describe :across_midnight? do
      it "returns false for daytime ranges" do
        _(subject.send(:across_midnight?, (AIXM.time('11:00')..AIXM.time('22:00')))).must_equal false
        _(subject.send(:across_midnight?, (AIXM.time('00:00')..AIXM.time('24:00')))).must_equal false
      end

      it "returns true for nighttime ranges" do
        _(subject.send(:across_midnight?, (AIXM.time('22:00')..AIXM.time('11:00')))).must_equal true
        _(subject.send(:across_midnight?, (AIXM.time('24:00')..AIXM.time('00:00')))).must_equal true
      end

      it "approximates sunrise to 6:00" do
        _(subject.send(:across_midnight?, (AIXM.time('05:59')..AIXM.time(:sunrise)))).must_equal false
        _(subject.send(:across_midnight?, (AIXM.time('06:01')..AIXM.time(:sunrise)))).must_equal true
      end

      it "approximates sunset to 18:00" do
        _(subject.send(:across_midnight?, (AIXM.time('17:59')..AIXM.time(:sunset)))).must_equal false
        _(subject.send(:across_midnight?, (AIXM.time('18:01')..AIXM.time(:sunset)))).must_equal true
      end
    end
  end

  describe NOTAM::Schedule::ScheduleArray do
    describe :cover? do
      subject do
        NOTAM::Schedule::ScheduleArray.new([AIXM.day(:monday), (AIXM.day(:friday)..AIXM.day(:saturday))])
      end

      it "returns true if the argument is equal to or covered by any entry" do
        _(subject.cover?(AIXM.day(:monday))).must_equal true
        _(subject.cover?(AIXM.day(:friday))).must_equal true
      end

      it "returns false if the argument is neither equal to nor covered by any entry" do
        _(subject.cover?(AIXM.day(:tuesday))).must_equal false
      end
    end

    describe :next do
      context 'dates' do
        it "shifts single dates one day forward" do
          subject = NOTAM::Schedule::ScheduleArray.new([AIXM.date('2000-01-01')])
          _(subject.next).must_equal [AIXM.date('2000-01-02')]
        end

        it "shifts multiple dates one day forward" do
          subject = NOTAM::Schedule::ScheduleArray.new([AIXM.date('2004-02-28'), AIXM.date('2004-12-31')])
          _(subject.next).must_equal [AIXM.date('2004-02-29'), AIXM.date('2005-01-01')]
        end

        it "shifts date ranges one day forward" do
          subject = NOTAM::Schedule::ScheduleArray.new([(AIXM.date('2004-02-01')..AIXM.date('2004-02-28'))])
          _(subject.next).must_equal [(AIXM.date('2004-02-02')..AIXM.date('2004-02-29'))]
        end
      end

      context 'days' do
        it "shifts single days one day forward" do
          subject = NOTAM::Schedule::ScheduleArray.new([AIXM.day(:monday)])
          _(subject.next).must_equal [AIXM.day(:tuesday)]
        end

        it "shifts multiple days one day forward" do
          subject = NOTAM::Schedule::ScheduleArray.new([AIXM.day(:monday), AIXM.day(:friday)])
          _(subject.next).must_equal [AIXM.day(:tuesday), AIXM.day(:saturday)]
        end

        it "shifts day ranges one day forward" do
          subject = NOTAM::Schedule::ScheduleArray.new([(AIXM.day(:monday)..AIXM.day(:wednesday))])
          _(subject.next).must_equal [(AIXM.day(:tuesday)..AIXM.day(:thursday))]
        end

        it "leaves any day untouched" do
          subject = NOTAM::Schedule::ScheduleArray.new([AIXM.day(:any)])
          _(subject.next).must_equal [AIXM.day(:any)]
        end
      end
    end
  end

end
