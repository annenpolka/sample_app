require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  describe "GET /home" do
    it "returns http success" do
      get "/static_pages/home"
      expect(response).to have_http_status(:success)
    end
    it "titleが正しい" do
      get  "/static_pages/home"
      dom = Capybara.string(response.body)
      expect(dom).to have_title("Home | Ruby on Rails Tutorial Sample App")
    end
  end

  describe "GET /help" do
    it "returns http success" do
      get "/static_pages/help"
      expect(response).to have_http_status(:success)
    end
    it "titleが正しい" do
      get  "/static_pages/help"
      dom = Capybara.string(response.body)
      expect(dom).to have_title("Help | Ruby on Rails Tutorial Sample App")
    end
  end

  describe "GET /about" do
    it "returns http success" do
      get "/static_pages/about"
      expect(response).to have_http_status(:success)
    end
    it "titleが正しい" do
      get  "/static_pages/about"
      dom = Capybara.string(response.body)
      expect(dom).to have_title("About | Ruby on Rails Tutorial Sample App")
    end
  end

end
