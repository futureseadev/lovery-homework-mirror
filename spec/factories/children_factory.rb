FactoryBot.define do
  factory :child do
    full_name { Faker::Name.name }
    birthdate { Faker::Date.birthday(min_age: 1, max_age: 12) }
    parent_name { Faker::Name.name }
  end
end
