# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Zeitwerk' do
  it 'eager loads all files' do
    expect {
      Zeitwerk::Loader.eager_load_all
    }.to_not raise_error
  end
end
