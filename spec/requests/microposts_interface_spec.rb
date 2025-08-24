# spec/requests/microposts_interface_spec.rb
require "rails_helper"

RSpec.describe "Microposts interface", type: :request do
  let!(:user)       { create(:user, password: "password", password_confirmation: "password") }
  let!(:other_user) { create(:user) }
  let!(:microposts) { create_list(:micropost, 35, user: user) }

  before do
    log_in_as(user)
  end

  def dom
    Capybara.string(response.body)
  end

  context "マイクロポスト画面の表示" do
    it "should paginate microposts" do
      get root_path
      expect(dom).to have_css('div.pagination')
    end
  end

  context "マイクロポストの作成" do
    it "should show errors but not create micropost on invalid submission" do
      expect {
        post microposts_path, params: { micropost: { content: "" } }
      }.not_to change(Micropost, :count)
      expect(dom).to have_css('div#error_explanation')
      expect(dom).to have_link('2', href: root_path(page: 2))
    end

    it "creates on valid submission" do
      content = "This micropost really ties the room together"
      expect {
        post microposts_path, params: { micropost: { content: content } }
      }.to change(Micropost, :count).by(1)
      expect(response).to redirect_to(root_url)
      follow_redirect!
      expect(response.body).to include(content)
    end
  end

  context "マイクロポストの削除" do
    let!(:micropost) { create(:micropost, user: user) }
    let!(:other_user_micropost) { create(:micropost, user: other_user) }

    it "shows delete links on own profile page" do
      get user_path(user)
      expect(dom).to have_css('a', text: 'delete')
    end

    it "should be able to delete own micropost" do
      expect {
        delete micropost_path(micropost)
    }.to change(Micropost, :count).by(-1)
    end

    it "should not have delete links on other user's profile page" do
      get user_path(other_user)
      expect(dom).not_to have_css('a', text: 'delete')
    end
  end

  context "マイクロポストのサイドバーの表示" do
    let!(:no_microposts_user) { create(:user) }
    let!(:one_micropost_user) { create(:user) }
    let!(:one_micropost) { create(:micropost, user: one_micropost_user) }

    it "should display the right micropost count" do
      get root_path
      expect(response.body).to match("#{microposts.count} microposts")
    end

    it "should user proper pluralization for zero microposts" do
      log_in_as(no_microposts_user)
      get root_path
      expect(response.body).to match("0 microposts")
    end
    it "should user proper pluralization for one micropost" do
      log_in_as(one_micropost_user)
      get root_path
      expect(response.body).to match("1 micropost")
    end
  end

  context "画像アップロード" do
    it "should hve a file input field for images" do
      get root_path
      expect(dom).to have_css('input[type="file"]')
    end

    it "should be able to attach an image" do
      cont = "This micropost really ties the room together."
      img  = Rack::Test::UploadedFile.new(
        Rails.root.join("spec/fixtures/kitten.jpg"), "image/jpeg"
      )

      expect {
        post microposts_path, params: { micropost: { content: cont, image: img } }
      }.to change(Micropost, :count).by(1)

      mp = Micropost.find_by!(content: cont, user_id: user.id)
      expect(mp.image).to be_attached
      expect(mp.image.blob.content_type).to eq("image/jpeg")
    end
  end


end
