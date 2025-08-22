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

  describe 'DELETE /api/v1/users/:id' do
    # 管理者ユーザーが他のユーザーを削除できる
    it '管理者は他のユーザーを削除できる' do
      login_user(admin.email, "secret123")
      json = response_json
      token = json[:user][:token]
      delete "/api/v1/users/#{user.id}",
          headers: { 'CONTENT_TYPE' => 'application/json', 'Authorization' => "Bearer #{token}"}
      expect(response).to have_http_status(:ok)
      # 削除されたユーザーが存在しないことを確認
      login_user(user.email, 'secret123')
      expect(response).to have_http_status(:unauthorized)
    end

    it '一般ユーザーは他のユーザーを削除できない' do
      # non_admin でログイン → token取得
      login_user(non_admin.email, "secret123")
      json = response_json
      token = json[:user][:token]
      delete "/api/v1/users/#{user.id}",
          headers: { 'CONTENT_TYPE' => 'application/json', 'Authorization' => "Bearer #{token}"}
      expect(response).to have_http_status(:forbidden)
    end

    it '非ログインユーザーはユーザーを削除できない' do
      token = "invalid"
      delete "/api/v1/users/#{user.id}",
          headers: { 'CONTENT_TYPE' => 'application/json', 'Authorization' => "Bearer #{token}"}
      expect(response).to have_http_status(:unauthorized)
    end

    it '存在しないユーザーIDでは404を返す' do
      login_user(admin.email, "secret123")
      json = response_json
      token = json[:user][:token]
      delete "/api/v1/users/999999",
          headers: { 'CONTENT_TYPE' => 'application/json', 'Authorization' => "Bearer #{token}"}
      expect(response).to have_http_status(:not_found)
    end

    it '管理者でも自分自身は削除できない' do
      login_user(admin.email, "secret123")
      json = response_json
      token = json[:user][:token]
      delete "/api/v1/users/#{admin.id}",
          headers: { 'CONTENT_TYPE' => 'application/json', 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:forbidden)
      # ユーザーが削除されていないことを確認（再度ログインできる）
      login_user(admin.email, 'secret123')
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /api/v1/users' do
    it 'ログインユーザーが自分の情報を更新できる' do
      login_user(user.email, "secret123")
      login_json = response_json
      token = login_json[:user][:token]
      patch "/api/v1/users/#{user.id}",
          params: { user: { name:  "新しい名前" } }.to_json,
          headers: { 'CONTENT_TYPE' => 'application/json', 'Authorization' => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      user_json = response_json
      expect(user_json.dig(:user, :name)).to eq("新しい名前")
    end
    it '非ログインユーザーは情報を更新できない' do
      token = "invalid"
      patch "/api/v1/users/#{user.id}",
          params: { user: { name:  "新しい名前" } }.to_json,
          headers: { 'CONTENT_TYPE' => 'application/json', 'Authorization' => "Bearer #{token}" }
      expect(response).to have_http_status(:unauthorized)
      #　名前が変更されていないことを確認
      get "/api/v1/users/#{user.id}",
          headers: { 'CONTENT_TYPE' => 'application/json'}
      user_json = response_json
      expect(user_json[:name]).not_to eq("新しい名前")
    end
  end
end
