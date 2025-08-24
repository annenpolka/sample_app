require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:user) { create(:user) }
  let(:from_email) { "annenpolka.lan@gmail.com" }
  describe "account_activation" do
    before do
      user.activation_token = User.new_token
    end
    subject(:mail) { UserMailer.account_activation(user) }
    context "メールの内容が正しい" do
      it do
        expect(mail.subject).to eq("Account activation")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq([from_email])
        expect(mail.body.encoded).to include(user.name)
        expect(mail.body.encoded).to include(user.activation_token)
        expect(mail.body.encoded).to include(CGI.escape(user.email))
      end
    end
  end

  describe "password_reset" do
    before do
      user.reset_token = User.new_token
    end
    subject(:mail) { UserMailer.password_reset(user) }

    context "メールの内容が正しい" do
      it do
        expect(mail.subject).to eq("Password reset")
        expect(mail.to).to eq([user.email])
        expect(mail.from).to eq([from_email])
        expect(mail.body.encoded).to include(user.reset_token)
        expect(mail.body.encoded).to include(CGI.escape(user.email))
      end
    end
  end
end
