require 'rails_helper'

RSpec.describe "ユーザーログイン", type: :request do
  let(:user) { create(:user) }

  # Small helpers to keep examples focused
  def dom_for(response)
    Capybara.string(response.body)
  end

  def expect_nav_for_logged_in(dom)
    aggregate_failures do
      expect(dom).to have_no_link(href: login_path)
      expect(dom).to have_link(href: logout_path)
      expect(dom).to have_link(href: user_path(user))
    end
  end

  def expect_nav_for_guest(dom)
    aggregate_failures do
      expect(dom).to have_link(href: login_path)
      expect(dom).to have_no_link(href: logout_path)
      expect(dom).to have_no_link(href: user_path(user))
    end
  end

  describe "ログイン（/login）" do
    describe "ログイン（POST /login）" do
      context "認証情報が正しい場合" do
        it "ユーザーのプロフィールへリダイレクトし、ログイン状態のナビゲーションが表示される" do
          log_in_as(user)

          expect(is_logged_in?).to be_truthy
          expect(response).to redirect_to(user_path(user))

          follow_redirect!
          expect(response).to render_template("users/show")
          expect_nav_for_logged_in(dom_for(response))
        end
      end

      context "メールアドレス・パスワードが無効な場合" do
        it "422でフォームを再表示し、フラッシュを表示後に消去する" do
          get login_path
          expect(response).to render_template("sessions/new")

          post login_path, params: { session: { email: "", password: "" } }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template("sessions/new")
          expect(flash).not_to be_empty

          get root_path
          expect(flash).to be_empty
        end
      end

      context "メールアドレスは有効だがパスワードが無効な場合" do
        it "ログインせず、422でフォームを再表示し、フラッシュを表示後に消去する" do
          get login_path
          expect(response).to render_template("sessions/new")

          post login_path, params: { session: { email: user.email, password: "invalid" } }
          expect(is_logged_in?).not_to be_truthy
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response).to render_template("sessions/new")
          expect(flash).not_to be_empty

          get root_path
          expect(flash).to be_empty
        end
      end
    end
  end

  describe "ログアウト（DELETE /logout）" do
    context "ログイン済みの場合" do
      before do
        log_in_as(user)
        follow_redirect!
      end

      it "ログアウトして303でトップへリダイレクトする" do
        delete logout_path
        expect(is_logged_in?).not_to be_truthy
        expect(response).to have_http_status(:see_other)
        expect(response).to redirect_to(root_url)
      end

      it "ログアウト後はゲスト用ナビゲーションが表示される" do
        delete logout_path
        follow_redirect!

        expect_nav_for_guest(dom_for(response))
      end

      it "should still work after logout in second window" do
        delete logout_path
        expect(response).to redirect_to(root_url)
        delete logout_path
        expect(response).to redirect_to(root_url)
      end
    end
  end

  describe "remember me機能" do
    it "remember付きでログイン" do
      log_in_as(user, remember_me: '1')
      expect(cookies[:remember_token]).not_to be_empty
    end

    it "rememberなしでログイン" do
      # Cookieを保存してログイン
      log_in_as(user, remember_me: '1')
      # Cookieが削除されていることを検証してからログイン
      log_in_as(user, remember_me: '0')
      expect(cookies[:remember_token]).to be_empty
    end
  end

end
