require 'rails_helper'

RSpec.describe Relationship, type: :model do
  let(:relationship) { create(:relationship, follower_id: create(:user).id, followed_id: create(:user).id)}

  context "フォロー関係のテスト" do
    it "should be valid" do
      expect(relationship).to be_valid
    end

    it "should require a follower_id" do
      relationship.follower_id = nil
      expect(relationship).not_to be_valid
    end

    it "should require a followed_id" do
      relationship.followed_id  = nil
      expect(relationship).not_to be_valid
    end

  end

end
