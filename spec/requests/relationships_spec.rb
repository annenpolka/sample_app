require 'rails_helper'

RSpec.describe "Relationships", type: :request do
  describe "フォロー・フォロワー関係" do
    context "ログイン確認" do
      let!(:relationship) { create(:relationship, follower_id: create(:user).id, followed_id: create(:user).id)}

      it "create should require logged-in user" do
        expect {
          post relationships_path
        }.not_to change(Relationship, :count)
        expect(response).to redirect_to(login_url)
      end

      it "destroy should require logged-in user" do
        expect {
          delete relationship_path(relationship)
        }.not_to change(Relationship, :count)
        expect(response).to redirect_to(login_url)
      end

    end
  end
end
