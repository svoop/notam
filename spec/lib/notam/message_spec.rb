# frozen_string_literal: true

require_relative '../../spec_helper'

describe NOTAM::Message do
  subject do
    NOTAM::Message.parse(NOTAM::Factory.message[:single])
  end

  describe :parse do
    context "fixtures" do
      if ENV['SPEC_SCOPE'].nil? || ENV['SPEC_SCOPE'] == 'none'
        it "parses all fixtures" do
          skip
        end
      else
        prepare_fixtures
        globber = ENV['SPEC_SCOPE'].match?('/') ? ENV['SPEC_SCOPE'].sub(/\//, '_') : '*'
        fixtures_path.glob("#{globber}.txt") do |fixture|
          it "parses fixture #{fixture.basename}" do
            text = fixture.read
            message = begin
              NOTAM::Message.parse(text)
            rescue => error
              $debug_info << "Fixture #{fixture.basename}:\n#{text}"
              if ENV['SPEC_SCOPE'] == 'all-fast'
                puts nil, nil, "Fast failing on...", error, error.backtrace
                exit 1
              else
                raise error
              end
            end
            raw_fingerprints = text.scan(/[QA-G]\)/)
            parsed_fingerprints = message.items.map(&:type).select { _1.length == 1 }.map { "#{_1})" }
            _(parsed_fingerprints - raw_fingerprints).must_be :empty?
          end
        end
      end
    end
  end

  describe :text do
    it "exposes the raw NOTAM text message" do
      _(subject.text).must_equal NOTAM::Factory.message[:single]
    end
  end

  describe :items do
    it "returns an array of items" do
      _(subject.items.count).must_equal 11
      subject.items.each do |item|
        _(item).must_be_kind_of NOTAM::Item
      end
    end
  end

  describe :data do
    it "returns a Hash containing the parsed NOTAM message" do
      _(subject.data).must_be_instance_of Hash
      _(subject.data.keys.sort).must_equal %i(
        center_point
        condition
        condition_group
        content
        created
        effective_at
        estimated_expiration?
        expiration_at
        fir
        five_day_schedules
        id
        id_number
        id_series
        id_year
        locations
        lower_limit
        new?
        no_expiration?
        purpose
        radius
        schedules
        scope
        source
        subject
        subject_group
        traffic
        translated_content
        upper_limit
      )
    end
  end

  describe :active? do
    context "D item missing" do
      subject do
        NOTAM::Message.parse(NOTAM::Factory.message[:single].sub(/D\).*\n/, ''))
      end

      it "returns true if the time is between effective_at and expiration_at" do
        _(subject.active?(at: Time.utc(2002, 2, 2))).must_equal true
      end

      it "returns false if the time is not between effective_at and expiration_at" do
        _(subject.active?(at: Time.utc(2000, 2, 2))).must_equal false
      end
    end

    context "D item present" do
      subject do
        NOTAM::Message.parse(NOTAM::Factory.message[:single])
      end

      it "returns true if the time is covered by active times" do
        _(subject.active?(at: Time.utc(2002, 1, 7, 10, 0))).must_equal true
      end

      it "returns false if the NOTAM is not covered by active times" do
        _(subject.active?(at: Time.utc(2002, 1, 1, 10, 0))).must_equal true
      end
    end
  end

  describe :departition do
    context "single NOTAM" do
      subject do
        NOTAM::Message.parse(NOTAM::Factory.message[:single])
      end

      it "does not add part_index and part_index_max keys to data" do
        _(subject.data.key? :part_index).must_equal false
        _(subject.data.key? :part_index_max).must_equal false
      end
    end

    context "partitioned NOTAM without END" do
      subject do
        NOTAM::Message.parse(NOTAM::Factory.message[:partitioned_without_end])
      end

      it "adds part_index and part_index_max to data" do
        _(subject.data[:part_index]).must_equal 10
        _(subject.data[:part_index_max]).must_equal 11
      end
    end

    context "partitioned NOTAM with END on E line" do
      subject do
        NOTAM::Message.parse(NOTAM::Factory.message[:partitioned_with_end])
      end

      it "adds part_index and part_index_max to data" do
        _(subject.data[:part_index]).must_equal 1
        _(subject.data[:part_index_max]).must_equal 2
      end
    end

    context "partitioned NOTAM with END anywhere" do
      subject do
        NOTAM::Message.parse(NOTAM::Factory.message[:partitioned_with_end_anywhere])
      end

      it "adds part_index and part_index_max to data" do
        _(subject.data[:part_index]).must_equal 2
        _(subject.data[:part_index_max]).must_equal 2
      end
    end
  end

  describe :itemize do
    it "splits message into an array of raw items" do
      subject = <<~END
        B0025/22 NOTAMR B1360/21
        Q) EDXX/QAFXX/IV/NBO/E /000/999/5123N01019E262
        A) EDWW EDGG EDMM B) 2201170851 C) 2204182259
        E) INFORMATION: EU RESTRICTIVE MEASURES ON BELARUS
        HTTPS://EUR-LEX.EUROPA.EU/LEGAL-CONTENT/EN/TXT/?URI=OJ:L:2021:219I:TO
        C) MAY BE SUBJECT TO PENALTIES OR FINES IN GERMANY.
        CREATED: 17 Jan 2022 08:51:00
        SOURCE: EUECYIY
      END
      _(NOTAM::Message.allocate.send(:itemize, subject)).must_equal([
        "B0025/22 NOTAMR B1360/21",
        "Q) EDXX/QAFXX/IV/NBO/E /000/999/5123N01019E262",
        "A) EDWW EDGG EDMM",
        "B) 2201170851",
        "C) 2204182259",
        "E) INFORMATION: EU RESTRICTIVE MEASURES ON BELARUS\nHTTPS://EUR-LEX.EUROPA.EU/LEGAL-CONTENT/EN/TXT/?URI=OJ:L:2021:219I:TO\nC) MAY BE SUBJECT TO PENALTIES OR FINES IN GERMANY.",
        "CREATED: 17 Jan 2022 08:51:00",
        "SOURCE: EUECYIY"
      ])
    end
  end
end
