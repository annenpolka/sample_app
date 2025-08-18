require 'rails_helper'

RSpec.describe "StaticPages", type: :request do
  before(:all) do
    @base_title = "Ruby on Rails Tutorial Sample App"
  end

  describe "GET /home" do
    it "returns http success" do
      get "/static_pages/home"
      expect(response).to have_http_status(:success)
    end
    it "titleが正しい" do
      get  "/static_pages/home"
      dom = Capybara.string(response.body)
      expect(dom).to have_title("Home | #{@base_title}")
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
      expect(dom).to have_title("Help | #{@base_title}")
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
      expect(dom).to have_title("About | #{@base_title}")
    end
  end

  describe "GET /contact" do
    it "returns http success" do
      get "/static_pages/contact"
      expect(response).to have_http_status(:success)
    end
    it "titleが正しい" do
      get  "/static_pages/contact"
      dom = Capybara.string(response.body)
      expect(dom).to have_title("Contact | #{@base_title}")
    end
  end
end
