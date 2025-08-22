require 'rails_helper'

RSpec.describe 'API JWT Authentication', type: :request do
  let(:user) { create(:user, password: 'secret123', password_confirmation: 'secret123') }
  let!(:users) { create_list(:user, 100)}
  let(:admin) { create(:user, password: 'secret123', password_confirmation: 'secret123', admin: true) }
  let(:non_admin) { create(:user, password: 'secret123', password_confirmation: 'secret123', admin: false) }

  def login_user(email, password)
    post '/api/v1/auth/login',
         params: { user: { email: email, password: password } }.to_json,
         headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
  end

  def response_json
    JSON.parse(response.body).with_indifferent_access
  end

  describe 'POST /api/v1/auth/login' do
    it 'returns JWT token on valid credentials' do
      login_user(user.email, 'secret123')

      expect(response).to have_http_status(:ok)
      json = response_json
      expect(json[:user][:token]).to be_present
    end

    it 'returns 401 on invalid credentials' do
      login_user(user.email, 'invalid')

      expect(response).to have_http_status(:unauthorized)
      json = response_json
      expect(json.dig(:user, :token)).not_to be_present
    end
  end

  describe 'GET /api/v1/users' do
    it 'ログインユーザーがユーザー一覧を取得する' do
      login_user(user.email, 'secret123')
      login_json = response_json
      token = login_json[:user][:token]
      get "/api/v1/users/",
          headers: { 'CONTENT_TYPE' => 'application/json', 'Authorization' => "Bearer #{token}"}

      users_json = response_json
      expect(users_json[:meta]).to be_present
      expect(users_json[:meta][:total_count]).to be_present
    end

    it '非ログインユーザーはユーザー一覧を取得できない' do
      token = "invalid"
      get "/api/v1/users/",
          headers: { 'CONTENT_TYPE' => 'application/json', 'Authorization' => "Bearer #{token}"}

      users_json = response_json
      expect(response).to have_http_status(:unauthorized)
    end

    it 'id指定でユーザー情報を取得する' do
      get "/api/v1/users/#{user.id}",
          headers: { 'CONTENT_TYPE' => 'application/json'}

      user_json = response_json
      expect(user_json[:name]).to be_present
      expect(user_json[:password_digest]).not_to be_present
    end
  end
end
