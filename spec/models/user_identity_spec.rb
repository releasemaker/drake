require 'rails_helper'

RSpec.describe UserIdentity, type: :model do
  it { is_expected.to belong_to(:user) }
end
