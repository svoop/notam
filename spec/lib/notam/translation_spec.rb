# frozen_string_literal: true

require_relative '../../spec_helper'

describe NOTAM do
  describe :expand_fir do
    it "returns array of FIRs" do
      _(NOTAM.expand_fir('LF')).must_equal %w(LFBB LFEE LFFF LFMM LFRR LFXX)
    end

    it "fails on unknown informal FIR" do
      _{ NOTAM.expand_fir('XX') }.must_raise ArgumentError
    end
  end

  describe :countries_for do
    it "returns array of countries for individual FIR" do
      _(NOTAM.countries_for('EDWW')).must_equal %i(DE)
    end

    it "fails on unknown individual FIR" do
      _{ NOTAM.countries_for('XXXX') }.must_raise KeyError
    end
  end

  describe :subject_for do
    it "converts known codes" do
      _(NOTAM.subject_for('AA')).must_equal :minimum_altitude
    end

    it "fails on unknown codes" do
      _{ NOTAM.subject_for('XY') }.must_raise KeyError
    end
  end

  describe :condition_for do
    it "converts known codes" do
      _(NOTAM.condition_for('AO')).must_equal :operational
    end

    it "fails on unknown codes" do
      _{ NOTAM.condition_for('XY') }.must_raise KeyError
    end
  end

  describe :traffic_for do
    it "converts known codes" do
      _(NOTAM.traffic_for('I')).must_equal :ifr
    end

    it "fails on unknown codes" do
      _{ NOTAM.traffic_for('X') }.must_raise KeyError
    end
  end

  describe :purpose_for do
    it "converts known codes" do
      _(NOTAM.purpose_for('K')).must_equal :checklist
    end

    it "fails on unknown codes" do
      _{ NOTAM.purpose_for('X') }.must_raise KeyError
    end
  end

  describe :scope_for do
    it "converts known codes" do
      _(NOTAM.scope_for('K')).must_equal :checklist
    end

    it "fails on unknown codes" do
      _{ NOTAM.scope_for('X') }.must_raise KeyError
    end
  end

  describe :purpose_for do
    it "converts known codes" do
      _(NOTAM.purpose_for('K')).must_equal :checklist
    end

    it "fails on unknown codes" do
      _{ NOTAM.purpose_for('X') }.must_raise KeyError
    end
  end

  describe :expand do
    it "expands known contractions" do
      _(NOTAM.expand('ABV')).must_equal :above
    end

    it "returns nil when expanding unknown contractions" do
      _(NOTAM.expand('XXX')).must_be :nil?
    end

    it "translates known contractions" do
      _(NOTAM.expand('ABV', translate: true)).must_equal 'above'
    end

    it "returns nil when translating unknown contractions" do
      _(NOTAM.expand('XXX', translate: true)).must_be :nil?
    end
  end

  describe 'FIRS' do
    it "has EN translations for all keys" do
      NOTAM::FIRS.keys.each do |key|
        _(I18n.t("firs.#{key}", raise: true)).wont_be :empty?
      end
    end

    it "has no missing keys still present in EN translation" do
      _(I18n.t(:firs).keys - NOTAM::FIRS.keys.map(&:to_sym)).must_be :none?
    end
  end

  describe 'SUBJECTS' do
    it "has EN translations for all keys" do
      NOTAM::SUBJECTS.values.each do |value|
        _(I18n.t("subjects.#{value}", raise: true)).wont_be :empty?
      end
    end

    it "has no missing keys still present in EN translation" do
      _(I18n.t(:subjects).keys - NOTAM::SUBJECTS.values).must_be :none?
    end
  end

  describe 'CONDITIONS' do
    it "has EN translations for all keys" do
      NOTAM::CONDITIONS.values.each do |value|
        _(I18n.t("conditions.#{value}", raise: true)).wont_be :empty?
      end
    end

    it "has no missing keys still present in EN translation" do
      _(I18n.t(:conditions).keys - NOTAM::CONDITIONS.values).must_be :none?
    end
  end

  describe 'TRAFFIC' do
    it "has EN translations for all keys" do
      NOTAM::TRAFFIC.values.each do |value|
        _(I18n.t("traffic.#{value}", raise: true)).wont_be :empty?
      end
    end

    it "has no missing keys still present in EN translation" do
      _(I18n.t(:traffic).keys - NOTAM::TRAFFIC.values).must_be :none?
    end
  end

  describe 'PURPOSES' do
    it "has EN translations for all keys" do
      NOTAM::PURPOSES.values.each do |value|
        _(I18n.t("purposes.#{value}", raise: true)).wont_be :empty?
      end
    end

    it "has no missing keys still present in EN translation" do
      _(I18n.t(:purposes).keys - NOTAM::PURPOSES.values).must_be :none?
    end
  end

  describe 'SCOPES' do
    it "has EN translations for all keys" do
      NOTAM::SCOPES.values.each do |value|
        _(I18n.t("scopes.#{value}", raise: true)).wont_be :empty?
      end
    end

    it "has no missing keys still present in EN translation" do
      _(I18n.t(:scopes).keys - NOTAM::SCOPES.values).must_be :none?
    end
  end

  describe 'CONTRACTIONS' do
    it "has EN translations for all keys" do
      NOTAM::CONTRACTIONS.values.each do |value|
        _(I18n.t("contractions.#{value}", raise: true)).wont_be :empty?
      end
    end

    it "has no missing keys still present in EN translation" do
      _(I18n.t(:contractions).keys - NOTAM::CONTRACTIONS.values).must_be :none?
    end
  end
end
