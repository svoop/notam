# frozen_string_literal: true

require_relative '../../spec_helper'

describe NOTAM::Message do
  subject do
    NOTAM::Message.parse(NOTAM::Factory.message)
  end

  describe :parse do
    unless ENV['SPEC_SCOPE'].nil?
      prepare_fixtures
      globber = ENV['SPEC_SCOPE'].match?('/') ? ENV['SPEC_SCOPE'].sub(/\//, '_') : '*'
      fixtures_path.glob("#{globber}.txt") do |fixture|
        it "parses fixture #{fixture.basename}" do
          text = fixture.read
          begin
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
        end
      end
    else
      it "parses all fixtures" do
        skip
      end
    end
  end

  describe :text do
    it "exposes the raw NOTAM text message" do
      _(subject.text).must_equal NOTAM::Factory.message
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
    end
  end

  describe :active? do
    context "D item missing" do
      subject do
        NOTAM::Message.parse(NOTAM::Factory.message.sub(/D\).*\n/, ''))
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
        NOTAM::Message.parse(NOTAM::Factory.message)
      end

      it "returns true if the time is covered by active times" do
        _(subject.active?(at: Time.utc(2002, 1, 7, 10, 0))).must_equal true
      end

      it "returns false if the NOTAM is not covered by active times" do
        _(subject.active?(at: Time.utc(2002, 1, 1, 10, 0))).must_equal true
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
