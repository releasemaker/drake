RSpec.shared_examples :authenticated_endpoint do
  context 'without logging in' do
    it 'redirects to authentication' do
      expect(do_the_thing).to redirect_to(sign_in_path)
    end
  end
end
