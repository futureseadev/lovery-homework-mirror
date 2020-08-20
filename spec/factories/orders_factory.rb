FactoryBot.define do
  factory :order do
    shipping_name { Faker::Name.name }
    address { [Faker::Address.street_address, Faker::Address.city, Faker::Address.state_abbr].join(', ') }
    zipcode { Faker::Address.zip_code }
    paid { false }
    product
  end
end
