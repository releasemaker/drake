require 'rails_helper'

RSpec.describe RepoMembership, type: :model do
  it { is_expected.to belong_to(:repo) }
  it { is_expected.to belong_to(:user) }
end
