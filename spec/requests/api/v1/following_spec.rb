require 'rails_helper'

RSpec.describe "Api::V1::Following", type: :request do
  describe "GET /api/v1/users/:id/following" do
    let!(:user) { create(:user) }
    let(:path) { following_api_v1_user_path(id: user.id) }
    context "フォローしているユーザーが存在する場合" do
      before do
        create(:relationship, follower_id: user.id, followed_id: create(:user).id)
      end

      it "フォロー中のユーザーを返す" do
        get path
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["following"].length).to eq(1)
        expect(JSON.parse(response.body)["meta"]["total_count"]).to eq(1)
      end

    end

    context "フォローしているユーザーが存在しない場合" do

      it "空の配列を返す" do
        get path
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["following"]).to eq([])
        expect(JSON.parse(response.body)["meta"]["total_count"]).to eq(0)
      end

    end

    context "存在しないユーザーIDの場合" do
      let(:path) { following_api_v1_user_path(id: 999999999) }

      it "404を返す" do
        get path
        expect(response).to have_http_status(404)
      end
    end

  end

  describe "GET /api/v1/:id/followers" do
    let!(:user) { create(:user) }
    let(:path) { followers_api_v1_user_path(id: user.id) }

    context "フォロワーが存在する場合" do
      before do
        create(:relationship, follower_id: create(:user).id, followed_id: user.id)
      end

      it "フォロワーを返す" do
        get path
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["followers"].length).to eq(1)
        expect(JSON.parse(response.body)["meta"]["total_count"]).to eq(1)
      end
    end

    context "フォロワーが存在しない場合" do
      it "空の配列を返す" do
        get path
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["followers"]).to eq([])
        expect(JSON.parse(response.body)["meta"]["total_count"]).to eq(0)
      end
    end

    context "存在しないユーザーIDの場合" do
      let(:path) { followers_api_v1_user_path(id: 999999999) }

      it "404を返す" do
        get path
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "POST /api/v1/users/:id/follow" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let(:path) { follow_api_v1_user_path(id: other_user.id) }

    context "認証済みユーザーが他のユーザーをフォローする場合" do
      let!(:token) { api_token_for(user, password: user.password) }

      it "存在するユーザーへのフォローが成功する" do
        post path, headers: auth_headers(token)
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["following"]).to be_truthy
      end

      it "すでにフォローしているユーザーへのフォローは成功する" do
        create(:relationship, follower_id: user.id, followed_id: other_user.id)
        post path, headers: auth_headers(token)
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["following"]).to be_truthy
      end

      it "存在しないユーザーへのフォローは404を返す" do
        post follow_api_v1_user_path(id: 999999999), headers: auth_headers(token)
        expect(response).to have_http_status(404)
      end
    end

    context "認証されていない場合" do
      it "401を返す" do
        post path
        expect(response).to have_http_status(401)
      end
    end
  end

  describe "DELETE /api/v1/users/:id/follow" do
    let!(:user) { create(:user) }
    let!(:other_user) { create(:user) }
    let!(:relationship) { create(:relationship, follower_id: user.id, followed_id: other_user.id) }
    let(:path) { follow_api_v1_user_path(id: other_user.id) }
    context "認証済みユーザーが他のユーザーのフォローを解除する場合" do
      let!(:token) { api_token_for(user, password: user.password) }

      it "存在するユーザーのフォロー解除が成功する" do
        delete path, headers: auth_headers(token)
        expect(response).to have_http_status(200)
        expect(JSON.parse(response.body)["unfollowed"]).to be_truthy
      end
      it "存在しないユーザーIDの場合は404を返す" do
        delete follow_api_v1_user_path(id: 999999999), headers: auth_headers(token)
        expect(response).to have_http_status(404)
      end
    end

    context "認証されていない場合" do
      it "401を返す" do
        delete path
        expect(response).to have_http_status(401)
      end
    end

  end
end