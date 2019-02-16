RSpec.shared_examples :authenticated_endpoint do
  context 'without logging in' do
    it 'redirects to authentication' do
      expect(do_the_thing).to redirect_to(sign_in_path)
    end
  end
end

RSpec.shared_examples :authenticated_api_endpoint do
  context 'without logging in' do
    it 'responds with Forbidden' do
      do_the_thing
      expect(response).to have_http_status(:forbidden)
    end
  end
end
