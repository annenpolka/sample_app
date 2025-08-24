require 'rails_helper'

RSpec.describe User, type: :model do
  before(:each) do
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  it "is vaild" do
    expect(@user).to be_valid
  end

  it "name should be present" do
    @user.name = ""
    expect(@user).not_to be_valid
  end

  it "email should be present" do
    @user.email = ""
    expect(@user).not_to be_valid
  end

  it "name should not be too long" do
    @user.name = "a" * 51
    expect(@user).not_to be_valid
  end

  it "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    expect(@user).not_to be_valid
  end

  it "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      expect(@user).to be_valid, "#{valid_address.inspect} should be valid"
    end
  end

    it "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      expect(@user).not_to be_valid, "#{invalid_address.inspect} should be invalid"
    end
  end

  it "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    expect(duplicate_user).not_to be_valid
  end


  it "email addresses should be saved as lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    expect(mixed_case_email.downcase).to eq @user.reload.email
  end

  it "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    expect(@user).not_to be_valid
  end

  it "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    expect(@user).not_to be_valid
  end

  it "authenticated? should return false for a user with nil digest" do
    expect(@user.authenticated?(:remember, '')).not_to be_truthy
  end

  context "dependent: :destroy" do
    let(:user) { create(:user) }

    it "destroys associated microposts" do
      user.microposts.create!(content: "Lorem ipsum")
      expect { user.destroy }.to change(Micropost, :count).by(-1)
    end
  end

  context "フォロー／フォロー解除" do
    let(:user_a) { create(:user) }
    let(:user_b) { create(:user) }

    it "should follow and unfollow a user" do
      expect(user_a).not_to be_following(user_b)
      user_a.follow(user_b)
      expect(user_a).to be_following(user_b)
      expect(user_b.followers).to include(user_a)
      user_a.unfollow(user_b)
      expect(user_a).not_to be_following(user_b)
    end

    it "ユーザーは自分自身をフォローできない" do
      user_a.follow(user_a)
      expect(user_a).not_to be_following(user_a)
    end


  end

end

