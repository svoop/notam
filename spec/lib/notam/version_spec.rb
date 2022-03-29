# frozen_string_literal: true

require_relative '../../spec_helper'

describe NOTAM do
  it "must be defined" do
    _(NOTAM::VERSION).wont_be_nil
  end
end
