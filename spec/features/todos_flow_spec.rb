require 'rails_helper'

RSpec.feature "TodosFlows", type: :feature do
  describe "todo itemの作成", js: true do
    let!(:user) { FactoryBot.create(:user) }
    valid_todo_item = "新規投稿"
    in_valid_todo_item = " "
    it "リストのトップに新規のtodo itemが作成されること" do
      login_as(user, :scope => :user)
      visit root_path
      fill_in("title", with: valid_todo_item)
      click_button("課題を追加する")
      new_todo_item = find('.table > tbody > tr:first-of-type td:nth-child(2) input:first-of-type')
      expect(new_todo_item.value).to eq(valid_todo_item)
    end
  end

  describe "todo itemを更新する", js: true do
    let(:user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    updated_todo_item_text = "updated"
    context "todo itemが正常である場合" do
      it "todo itemを更新すること" do
        login_as(user_with_todo_items, :scope => :user)
        visit root_path
        todo_item = user_with_todo_items.todo_items.first
        find("#todoItem_title-#{todo_item.id}").send_keys(updated_todo_item_text)
        sleep 2
        visit root_path
        updated_todo_item = find('.table > tbody > tr:first-of-type td:nth-child(2) input:first-of-type')
        expect(updated_todo_item.value).to eq(todo_item.title + updated_todo_item_text)
      end
    end
    context "todo itemが不正である場合", js: true do
      it "エラーメッセージを表示すること" do
        login_as(user_with_todo_items, :scope => :user)
        visit root_path
        todo_item = user_with_todo_items.todo_items.first
        fill_in("todoItem_title-#{todo_item.id}", with: " ")
        expect(page).to have_content("can't be blank")
      end
    end
  end

  describe "todo itemを削除する", js: true do
    let(:user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    it "todo itemを削除すること" do
      login_as(user_with_todo_items, :scope => :user)
      visit root_path
      todo_item = user_with_todo_items.todo_items.first
      row = find('.table > tbody > tr:first-of-type td:nth-child(3)')
      accept_confirm do
        row.click_button("Delete")
      end
      expect(page).to_not have_content(todo_item.title)
    end
  end

  describe "todo itemsをフィルタリングする", js: true do
    let(:user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    let(:user_with_completed_todo_items) { FactoryBot.create(:user_with_completed_todo_items) }
    it "完了済みのtodo itemsを非表示にすること" do
      login_as(user_with_todo_items, :scope => :user)
      visit root_path
      todo_item = user_with_todo_items.todo_items.first
      check("complete-#{todo_item.id}")
      click_button("Hide Completed Items")
      within(".table-responsive tbody") do
        expect(page).to_not have_content(todo_item.title)
      end
    end
    it "未完了のtodo itemsだけを表示すること" do
      login_as(user_with_completed_todo_items, :scope => :user)
      visit root_path
      todo_items = user_with_completed_todo_items.todo_items
      todo_items.each do |todo_item|
        expect(find("#todoItem_title-#{todo_item.id}").value).to eq(todo_item.title)
      end
      click_button("Hide Completed Items")
      within(".table-responsive tbody") do
        todo_items.each do |todo_item|
          expect(page).to_not have_content(todo_item.title)
        end
      end
    end
  end
end
