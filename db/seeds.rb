# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
2.times do |i|
  User.create(email: "user-#{i+1}@example.com", password: "password", password_confirmation: "password")
end

User.all.each do |u|
  10.times do |i|
    u.todo_items.create(title: "課題 #{i+1} by #{u.email}", complete: i % 3 === 0 ? true : false)
  end
end
