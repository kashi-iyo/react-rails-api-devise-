require 'rails_helper'

RSpec.feature "HomepageFlows", type: :feature do
  describe "ホームページ" do
    let!(:user) { FactoryBot.create(:user) }
    context "ユーザーが認可されていない場合" do
      it "新規登録へのリンクを返す" do
        visit authenticated_root_path
        expect(page).to have_content("")
        expect(page).to have_current_path(root_path)
      end
    end
    context "ユーザーが認証済みの場合" do
      it "自分のtodo itemsを返す" do
        sign_in user
        visit authenticated_root_path
        expect(page).to have_content("My To Do Items")
        expect(page).to have_current_path(authenticated_root_path)
      end
    end
  end
end
