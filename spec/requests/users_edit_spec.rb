require 'rails_helper'

RSpec.describe "UsersEdit", type: :request do
  let(:user) { create(:user) }

  describe "GET /users_edit" do

    it "successful edit" do
      get edit_user_path(user)
      expect(response).to render_template("users/edit")
      name = "Foo Bar"
      email = "foo@bar.com"
      patch user_path, params: { user: { name:  name,
                                         email: email,
                                         password: "",
                                         password_confirmation: "" } }
      expect(flash).not_to be_empty
      expect(response).to redirect_to(user)
      user.reload
      expect(name).to eq user.name
      expect(email).to eq user.email

    end

    it "unsuccessful edit" do
      get edit_user_path(user)
      expect(response).to render_template("users/edit")

      patch user_path, params: { user: { name:  "",
                                         email: "foo@invalid",
                                         password: "foo",
                                         password_confirmation: "bar" } }
      expect(response).to render_template("users/edit")
    end
  end
end
