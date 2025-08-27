require 'rails_helper'

RSpec.describe 'API JWT Authentication', type: :request do
  let(:user) { create(:user, password: 'secret123', password_confirmation: 'secret123') }
  let!(:users) { create_list(:user, 100) }
  let(:admin) { create(:user, password: 'secret123', password_confirmation: 'secret123', admin: true) }
  let(:non_admin) { create(:user, password: 'secret123', password_confirmation: 'secret123', admin: false) }

  let(:token_for_user) { token_for(user) }
  let(:token_for_admin) { token_for(admin) }
  let(:token_for_non_admin) { token_for(non_admin) }

  describe 'POST /api/v1/auth/login' do
    context 'with valid credentials' do
      it 'returns JWT token' do
        log_in_as(user, password: 'secret123')
        expect(response).to have_http_status(:ok)
        expect(response_json.dig(:user, :token)).to be_present
      end
    end

    context 'with invalid credentials' do
      it 'returns 401' do
        log_in_as(user, password: 'invalid')
        expect(response).to have_http_status(:unauthorized)
        expect(response_json.dig(:user, :token)).not_to be_present
      end
    end
  end

  describe 'GET /api/v1/users' do
    context 'when authenticated' do
      it '一覧を返す（ページネーション情報を含む）' do
        get api_v1_users_path, headers: auth_headers(token_for_user)
        expect(response_json[:meta]).to be_present
        expect(response_json[:meta][:total_count]).to be_present
      end
    end

    context 'when unauthenticated' do
      it '401 を返す' do
        get api_v1_users_path, headers: auth_headers('invalid')
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/v1/users/:id' do
    context '公開プロフィール' do
      it 'id指定でユーザー情報を取得する' do
        get api_v1_user_path(user.id), headers: api_headers
        expect(response_json[:name]).to be_present
        expect(response_json[:password_digest]).not_to be_present
      end
    end
  end

  describe 'DELETE /api/v1/users/:id' do
    context 'as admin' do
      it '他のユーザーを削除できる' do
        delete api_v1_user_path(user.id), headers: auth_headers(token_for_admin)
        expect(response).to have_http_status(:ok)

        # 削除されたユーザーでログインできないこと
        log_in_as(user, password: 'secret123')
        expect(response).to have_http_status(:unauthorized)
      end

      it '存在しないユーザーIDでは404' do
        delete api_v1_user_path(999999), headers: auth_headers(token_for_admin)
        expect(response).to have_http_status(:not_found)
      end

      it '自分自身は削除できない' do
        delete api_v1_user_path(admin.id), headers: auth_headers(token_for_admin)
        expect(response).to have_http_status(:forbidden)
        # まだログイン可能
        log_in_as(admin, password: 'secret123')
        expect(response).to have_http_status(:ok)
      end
    end

    context 'as non-admin' do
      it '他人を削除できず403' do
        delete api_v1_user_path(user.id), headers: auth_headers(token_for_non_admin)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when unauthenticated' do
      it '401 を返す' do
        delete api_v1_user_path(user.id), headers: auth_headers('invalid')
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/users/:id' do
    context 'as self' do
      it '自分の情報を更新できる' do
        patch api_v1_user_path(user.id),
              params: { user: { name:  "新しい名前" } }.to_json,
              headers: auth_headers(token_for_user)

        expect(response).to have_http_status(:ok)
        expect(response_json.dig(:user, :name)).to eq("新しい名前")
      end
    end

    context 'as non-admin' do
      it '他人の情報は更新できず403' do
        other = create(:user, password: 'secret123', password_confirmation: 'secret123')
        patch api_v1_user_path(other.id),
              params: { user: { name:  "勝手に変更" } }.to_json,
              headers: auth_headers(token_for_non_admin)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'as admin' do
      it '他人の情報を更新できる' do
        target = create(:user, password: 'secret123', password_confirmation: 'secret123', admin: false)
        patch api_v1_user_path(target.id),
              params: { user: { name:  "管理者が更新", admin: true } }.to_json,
              headers: auth_headers(token_for_admin)
        expect(response).to have_http_status(:ok)
        expect(response_json.dig(:user, :name)).to eq("管理者が更新")
        expect(target.reload.admin).to be true
      end
    end

    context 'when unauthenticated' do
      it '401 を返し、変更されない' do
        patch api_v1_user_path(user.id),
              params: { user: { name:  "新しい名前" } }.to_json,
              headers: auth_headers('invalid')
        expect(response).to have_http_status(:unauthorized)
        get api_v1_user_path(user.id), headers: api_headers
        expect(response_json[:name]).not_to eq("新しい名前")
      end
    end
  end
end
