# frozen_string_literal: true

require_relative '../../spec_helper'

describe NOTAM::Schedule do
  context 'public' do
    describe :parse do
      it "must extract schedule :date_with_exception" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:date_with_exception], base_date: AIXM.date('2000-02-01'))
        _(subject.actives).must_be_instance_of NOTAM::Schedule::Dates
        _(subject.actives).must_equal [(AIXM.date('2000-02-01')..AIXM.date('2000-03-31'))]
        _(subject.times).must_equal [(AIXM.time('07:00')..AIXM.time('11:00'))]
        _(subject.inactives).must_be_instance_of NOTAM::Schedule::Days
        _(subject.inactives).must_equal [AIXM.day(:friday)]
      end

      it "must extract schedule :day_with_exception" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:day_with_exception], base_date: AIXM.date('2000-02-01'))
        _(subject.actives).must_be_instance_of NOTAM::Schedule::Days
        _(subject.actives).must_equal [(AIXM.day(:monday)..AIXM.day(:tuesday))]
        _(subject.times).must_equal [(AIXM.time('07:00')..AIXM.time('19:00'))]
        _(subject.inactives).must_be_instance_of NOTAM::Schedule::Dates
        _(subject.inactives).must_equal [AIXM.date('2000-02-15')]
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
      it "consolidates :date_with_exception" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:date_with_exception], base_date: AIXM.date('2000-02-02'))
        _(subject.slice(AIXM.date('2000-02-02'), AIXM.date('2000-02-05')).to_s).must_equal(
          "#<NOTAM::Schedule actives: [2000-02-02..2000-02-03, 2000-02-05], times: [07:00 UTC..11:00 UTC], inactives: []>"
        )
      end

      it "consolidates :day_with_exception" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:day_with_exception], base_date: AIXM.date('2000-01-01'))
        _(subject.slice(AIXM.date('2000-02-14'), AIXM.date('2000-02-27')).to_s).must_equal(
          "#<NOTAM::Schedule actives: [2000-02-14, 2000-02-21..2000-02-22], times: [07:00 UTC..19:00 UTC], inactives: []>"
        )
      end

      it "defaults to a time frame of one day" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:daytime], base_date: AIXM.date('2000-01-01'))
        _(subject.slice(AIXM.date('2000-02-02')).to_s).must_equal(
          "#<NOTAM::Schedule actives: [2000-02-02], times: [sunrise..sunset], inactives: []>"
        )
      end

      it "accepts custom time frames" do
        subject = NOTAM::Schedule.parse(NOTAM::Factory.schedule[:daytime], base_date: AIXM.date('2000-01-01'))
        _(subject.slice(AIXM.date('2000-02-02'), AIXM.date('2000-02-03')).to_s).must_equal(
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
        NOTAM::Schedule.parse(NOTAM::Factory.schedule[:daytime], base_date: AIXM.date('2025-01-01')).slice(AIXM.date('2025-07-01'))
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
        _(subject.active?(at: Time.utc(2000, 1, 1, 12, 0), xy: AIXM.xy(lat: 49.01614, long: 2.54423))).must_equal true
      end

      it "returns false if the given time is not covered by active times" do
        _(subject.active?(at: Time.utc(2000, 1, 1, 1, 0), xy: AIXM.xy(lat: 49.01614, long: 2.54423))).must_equal false
      end
    end
  end

  context 'private' do
    subject do
      NOTAM::Schedule.allocate
    end

    describe :dates_from do
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
  end

end
