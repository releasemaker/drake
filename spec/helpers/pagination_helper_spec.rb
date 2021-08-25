# frozen_string_literal: true

require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the PaginationHelper. For example:
#
# describe PaginationHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe PaginationHelper, type: :helper do
  describe '#page' do
    subject { helper.page }
    context 'when page is specified' do
      before do
        helper.params[:page] = 3
      end
      it { is_expected.to eq(3) }
    end
    context 'when page is not specified' do
      it { is_expected.to eq(1) }
    end
  end

  describe '#per_page' do
    subject { helper.per_page }
    context 'when per_page is specified' do
      before do
        helper.params[:per_page] = 30
      end
      it { is_expected.to eq(30) }
    end
    context 'when per_page is not specified' do
      it { is_expected.to eq(25) }
    end
  end
end
