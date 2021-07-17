FactoryBot.define do
  factory :body_temperature do
    association :user
    temperature { rand(36.0..38.0).floor(1) }
    measurement_date { Faker::Date.in_date_period }
  end
end
