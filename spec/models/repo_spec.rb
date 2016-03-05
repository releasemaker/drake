require 'rails_helper'

RSpec.describe Repo, type: :model do
  it { is_expected.to have_many(:repo_memberships) }
end
