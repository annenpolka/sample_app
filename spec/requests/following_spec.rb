require 'rails_helper'

RSpec.describe "Following", type: :request do
  describe "/users/id/following" do
    let!(:user_a) { create(:user) }
    let!(:user_b) { create(:user) }
    let!(:user_c) { create(:user) }
    let!(:user_d) { create(:user) }
    before do
      log_in_as(user_a)
    end

    context "フォローページ画面のテスト" do
      let!(:relationship_atob) { create(:relationship, follower_id: user_a.id, followed_id: user_b.id)}
      let!(:relationship_atoc) { create(:relationship, follower_id: user_a.id, followed_id: user_c.id)}
      let!(:relationship_btoa) { create(:relationship, follower_id: user_b.id, followed_id: user_a.id)}
      let!(:relationship_dtoa) { create(:relationship, follower_id: user_d.id, followed_id: user_a.id)}

      it "following page" do
        get following_user_path(user_a)
        expect(response).to have_http_status(:success)
        expect(user_a.following).not_to be_empty
        expect(response.body).to match(user_a.following.count.to_s)
        dom = Capybara.string(response.body)
        user_a.following.each do |user|
          expect(dom).to have_link(href: user_path(user))
        end
      end

      it "followers page" do
        get followers_user_path(user_a)
        expect(response).to have_http_status(:success)
        expect(user_a.followers).not_to be_empty
        expect(response.body).to match(user_a.followers.count.to_s)
        dom = Capybara.string(response.body)
        user_a.followers.each do |user|
          expect(dom).to have_link(href: user_path(user))
        end
      end
    end

    context "フォローのテスト" do
      it "should follow a user the standard way" do
        expect {
          post relationships_path, params: { followed_id: user_b.id }
        }.to change(user_a.following, :count).by(1)
        expect(response).to redirect_to(user_b)
      end

      it "should follow a user with Hotwire" do
          expect {
            post relationships_path(format: :turbo_stream), params: { followed_id: user_b.id }
          }.to change(user_a.following, :count).by(1)
      end
    end

    context "フォロー解除のテスト" do
      before do
        user_a.follow(user_b)
      end
      let(:relationship) { user_a.active_relationships.find_by(followed_id: user_b.id) }

      it "should unfollow a user the standard way" do
        expect {
          delete relationship_path(relationship)
        }.to change(user_a.following, :count).by(-1)
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(user_b)
      end

      it "should unfollow a user with Hotwire" do
        expect {
          delete relationship_path(relationship, format: :turbo_stream)
        }.to change(user_a.following, :count).by(-1)
      end
    end

  end
end
