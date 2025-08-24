require 'rails_helper'

RSpec.describe Micropost, type: :model do
  let!(:user) { create(:user) }
  let(:micropost) { user.microposts.build(content: "Lorem ipsum") }
  let!(:orange)      { create(:micropost, :orange,        user: user) }
  let!(:tau)         { create(:micropost, :tau_manifesto, user: user) }
  let!(:cat_video)   { create(:micropost, :cat_video,     user: user) }
  let!(:most_recent) { create(:micropost, :most_recent,   user: user) }

  context "micropostのバリデーション" do
    it "should be valid" do
      expect(micropost).to be_valid
    end

    it "user id should be present" do
      micropost.user_id = nil
      expect(micropost).not_to be_valid
    end

    it "content should be present" do
      micropost.content = "    "
      expect(micropost).not_to be_valid
    end

    it "content should be at most 140 characters" do
      micropost.content = "a" * 141
      expect(micropost).not_to be_valid
    end

    it "order should be most recent first" do
      expect(Micropost.first).to eq(most_recent)
    end

  end
end
