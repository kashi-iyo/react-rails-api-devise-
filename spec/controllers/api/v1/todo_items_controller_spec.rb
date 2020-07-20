require 'rails_helper'

RSpec.describe Api::V1::TodoItemsController, type: :controller do
  render_views
  describe "indexアクション" do
    let!(:user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    context "認証済みのユーザーの場合" do
      it "現在のユーザーのtodo itemsを表示すること" do
        sign_in user_with_todo_items
        get :index, format: :json
        expect(response).to be_successful
      end
      it "200レスポンスを返すこと" do
        sign_in user_with_todo_items
        get :index, format: :json
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(JSON.parse(user_with_todo_items.todo_items.to_json))
      end
    end
    context "ゲストユーザーの場合" do
      it "401を返すこと" do
        get :index, format: :json
        expect(response.status).to eq(401)
      end
    end
  end

  describe "showアクション" do
    let!(:user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    let!(:another_user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    context "認証済みのユーザーの場合" do
      it "todo itemsを返すこと" do
        todo_item = user_with_todo_items.todo_items.first
        sign_in user_with_todo_items
        get :show, format: :json, params: { id: todo_item.id }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)).to eq(JSON.parse(todo_item.to_json))
      end
      it "todo itemsを別のユーザーに見えないようにすること" do
        another_users_todo_item =  another_user_with_todo_items.todo_items.first
        sign_in user_with_todo_items
        get :show, format: :json, params: { id: another_users_todo_item.id }
        expect(response.status).to eq(401)
      end
    end
    context "ゲストユーザーの場合" do
      it "401を返すこと" do
        todo_item = user_with_todo_items.todo_items.first
        get :show, format: :json, params: { id: todo_item.id }
        expect(response.status).to eq(401)
      end
    end
  end

  describe "createアクション" do
    let!(:user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    let!(:another_user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    context "認証済みユーザーの場合" do
      it "todo itemsを返すこと" do
        sign_in user_with_todo_items
        new_todo = { title: "新規投稿", user: user_with_todo_items }
        post :create, format: :json, params: { todo_item: new_todo }
        expect(response.status).to eq(201)
        expect(JSON.parse(response.body)["title"]).to eq(new_todo[:title])
      end
      it "todo itemを作成すること" do
        sign_in user_with_todo_items
        new_todo = { title: "新規投稿", user: user_with_todo_items }
        expect { post :create, format: :json, params: { todo_item: new_todo } }.to change{ TodoItem.count }.by(1)
      end
      it "不正な場合にメッセージを返すこと" do
        sign_in user_with_todo_items
        invalid_new_todo = { title: "", user: user_with_todo_items }
        expect { post :create, format: :json, params: { todo_item: invalid_new_todo } }.to_not change{ TodoItem.count }
        expect(response.status).to eq(422)
      end
    end
    context "認可されていないユーザーの場合" do
      it "ユーザーが他のユーザーのtodo itemsを作成するのを許可しないこと" do
        sign_in user_with_todo_items
        new_todo = { title: "異なるアカウントでの投稿", user: another_user_with_todo_items }
        post :create, format: :json, params: { todo_item: new_todo }
        expect(JSON.parse(response.body)["user_id"]).to eq(user_with_todo_items.id)
        expect(JSON.parse(response.body)["user_id"]).not_to eq(another_user_with_todo_items.id)
      end
    end
    context "ゲストユーザーの場合" do
      it "401を返すこと" do
        new_todo = { title: "投稿", user: user_with_todo_items }
        post :create, format: :json, params: { todo_item: new_todo }
        expect(response.status).to eq(401)
      end
    end
  end

  describe "updateアクション" do
    let!(:user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    let!(:another_user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    context "認証済みユーザーの場合" do
      it "todo itemを返すこと" do
        sign_in user_with_todo_items
        updated_todo = user_with_todo_items.todo_items.first
        updated_todo_title = "updated"
        put :update, format: :json, params: { todo_item: { title: updated_todo_title }, id: updated_todo.id }
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)["title"]).to eq(updated_todo_title)
      end
      it "不正なデータが送信された場合はメッセージを表示すること" do
        sign_in user_with_todo_items
        updated_todo = user_with_todo_items.todo_items.first
        updated_todo_title = ""
        put :update, format: :json, params: { todo_item: { title: updated_todo_title }, id: updated_todo.id }
        expect(response.status).to eq(422)
      end
    end
    context "認可されていないユーザーの場合" do
      it "他のユーザーのtodo itemは更新できないこと" do
        sign_in user_with_todo_items
        another_users_updated_todo = another_user_with_todo_items.todo_items.first
        updated_todo_title = "updated"
        put :update, format: :json, params: { todo_item: { title: updated_todo_title }, id: another_users_updated_todo.id }
        expect(response.status).to eq(401)
      end
    end
    context "ゲストユーザーの場合" do
      it "unauthorizedを返すこと" do
        updated_todo = user_with_todo_items.todo_items.first
        new_todo_title = "updated"
        put :update, format: :json, params: { todo_item: { title: new_todo_title }, id: updated_todo.id }
        expect(response.status).to eq(401)
      end
    end
  end

  describe "destroyアクション" do
    let!(:user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    let!(:another_user_with_todo_items) { FactoryBot.create(:user_with_todo_items) }
    context "認証済みユーザーの場合" do
      it "no contentステータスを返すこと" do
        sign_in user_with_todo_items
        destroyed_todo = user_with_todo_items.todo_items.first
        delete :destroy, format: :json, params: { id: destroyed_todo.id }
        expect(response.status). to eq(204)
      end
      it "todo itemを正常に削除できること" do
        sign_in user_with_todo_items
        destroyed_todo = user_with_todo_items.todo_items.first
        expect { delete :destroy, format: :json, params: { id: destroyed_todo.id } }.to change{ TodoItem.count }.by(-1)
      end
    end
    context "認証されていないユーザーの場合" do
      it "他のユーザーのtodo itemは削除できないこと" do
        sign_in user_with_todo_items
        another_users_todo = another_user_with_todo_items.todo_items.first
        expect { delete :destroy, format: :json, params: { id: another_users_todo } }.to_not change{ TodoItem.count }
      end
    end
    context "ゲストユーザーの場合" do
      it "unauthorizedを返すこと" do
        destroyed_todo = user_with_todo_items.todo_items.first
        delete :destroy, format: :json, params: { id: destroyed_todo.id }
        expect(response.status).to eq(401)
      end
    end
  end

end
