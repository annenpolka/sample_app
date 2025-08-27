require 'rails_helper'

RSpec.describe 'API Me endpoints', type: :request do
  let(:user) { create(:user, password: 'secret123', password_confirmation: 'secret123') }

  let(:token_for_user) { token_for(user) }

  describe 'GET /api/v1/me' do
    context 'when authenticated' do
      it '現在のユーザー情報を返す' do
        get api_v1_me_path, headers: auth_headers(token_for_user)
        expect(response).to have_http_status(:ok)
        expect(response_json[:name]).to be_present
        expect(response_json[:password_digest]).to be_nil
      end
    end

    context 'when unauthenticated' do
      it '401 を返す' do
        get api_v1_me_path, headers: auth_headers('invalid')
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/v1/me' do
    context 'when authenticated' do
      it '自分の情報を更新できる' do
        patch api_v1_me_path,
              params: { user: { name: 'Me Updated' } }.to_json,
              headers: auth_headers(token_for_user)
        expect(response).to have_http_status(:ok)
        expect(response_json.dig(:user, :name)).to eq('Me Updated')
      end
    end

    context 'when unauthenticated' do
      it '401 を返す' do
        original_name = user.name
        patch api_v1_me_path,
              params: { user: { name: 'Me Updated' } }.to_json,
              headers: auth_headers('invalid')
        expect(response).to have_http_status(:unauthorized)
        # 変更が反映されていないことを確認
        get api_v1_user_path(user.id), headers: api_headers
        expect(response_json[:name]).to eq(original_name)
      end
    end
  end
end
