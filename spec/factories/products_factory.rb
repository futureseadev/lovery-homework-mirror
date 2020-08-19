FactoryBot.define do
  factory :product do
    name  { Faker::Appliance.brand }
    description { Faker::Appliance.equipment }
    price_cents { 1000 }
    age_low_weeks { 0 }
    age_high_weeks { 12 }
  end
end
