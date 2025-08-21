require 'rails_helper'

RSpec.describe 'API JWT Authentication', type: :request do
  let(:user) { create(:user, password: 'secret123', password_confirmation: 'secret123') }

  describe 'POST /api/v1/auth/login' do
    it 'returns JWT token on valid credentials' do
      post '/api/v1/auth/login',
           params: { user: { email: user.email, password: 'secret123' } }.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body).with_indifferent_access
      expect(json.dig(:user, :token)).to be_present
    end

    it 'returns 401 on invalid credentials' do
      post '/api/v1/auth/login',
           params: { user: { email: user.email, password: 'invalid' } }.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body).with_indifferent_access
      expect(json.dig(:user, :token)).not_to be_present
    end
  end

  describe 'POST /api/v1/users/show' do
    it 'get user info on valid credentials' do
      post '/api/v1/auth/login',
           params: { user: { email: user.email, password: 'secret123' } }.to_json,
           headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }

      post_json = JSON.parse(response.body).with_indifferent_access
      token = post_json.dig(:user, :token)

      get '/api/v1/users/show',
          headers: { 'CONTENT_TYPE' => 'application/json', 'AUTHORIZATION' => token }

      puts JSON.parse(response.body)
      # expect(response)
    end
  end
end
