RSpec.feature 'Authentication' do
  context 'when OAuth has failed' do
    before do
      OmniAuth.config.mock_auth[:github] = :invalid_credentials
    end

    let(:do_the_thing) { visit '/auth/github/callback' }

    it "adds a flash message" do
      do_the_thing
      expect(page).to have_content("something went wrong during authentication with Github")
    end
  end
end
