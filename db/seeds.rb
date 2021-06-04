# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create!(name: 'Test User',
             email: 'test@example.com',
             admin: true,
             password: 'foobar',
             password_confirmation: 'foobar')

199.times do |n|
  name  = Gimei.kanji
  email = "test-#{n + 1}@example.com"
  password = 'password'
  User.create!(name: name,
               email: email,
               admin: false,
               password: password,
               password_confirmation: password)
end
