require 'rails_helper'

RSpec.describe 'API JWT Authentication', type: :request do
  describe 'POST /api/v1/auth/login' do
    it 'returns JWT token on valid credentials' do
      user = create(:user, password: 'secret123', password_confirmation: 'secret123')

      post '/api/v1/auth/login',
           params: { email: user.email, password: 'secret123' }.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['token']).to be_present
    end
  end
end

