FactoryBot.define do
  factory :user do
    name { Gimei.name }
    email { Faker::Internet.safe_email(name: name) }
    password { Faker::Internet.password }
  end
end
