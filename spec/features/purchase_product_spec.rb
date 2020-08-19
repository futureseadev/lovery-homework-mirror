require 'rails_helper'

RSpec.feature 'Purchase Product', type: :feature do
  let!(:product) { FactoryBot.create(:product) }
  let!(:child) { FactoryBot.create(:child) }

  scenario 'Creates an order and charges us' do
    visit '/'

    within '.products-list .product' do
      click_on 'More Details…'
    end

    click_on 'Buy Now $10.00'

    fill_in 'order[credit_card_number]', with: '4111111111111111'
    fill_in 'order[expiration_month]', with: 12
    fill_in 'order[expiration_year]', with: 25
    fill_in 'order[shipping_name]', with: 'Pat Jones'
    fill_in 'order[address]', with: '123 Any St'
    fill_in 'order[zipcode]', with: 83_701
    fill_in 'order[child_full_name]', with: 'Kim Jones'
    fill_in 'order[child_birthdate]', with: '2019-03-03'

    click_on 'Purchase'

    expect(page).to have_content('Thanks for Your Order')
    expect(page).to have_content(Order.last.user_facing_id)
    expect(page).to have_content('Kim Jones')
  end

  scenario 'Notifies of error when gifing to a child not found in our system' do
    visit '/'

    within '.products-list .product' do
      click_on 'More Details…'
    end

    click_on 'Buy Now $10.00'

    fill_in 'order[credit_card_number]', with: '4111111111111111'
    fill_in 'order[expiration_month]', with: 12
    fill_in 'order[expiration_year]', with: 25
    fill_in 'order[shipping_name]', with: 'Pat Jones'
    fill_in 'order[address]', with: '123 Any St'
    fill_in 'order[zipcode]', with: 83_701
    fill_in 'order[child_full_name]', with: 'Kim Jones'
    fill_in 'order[child_birthdate]', with: '2019-03-03'
    check 'order[as_gift]'

    click_on 'Purchase'

    expect(page).to have_content('Child not found with the provided information.')
  end

  scenario 'Processes order successfully when gifting to a child that exists in our system', js: true do
    visit '/'

    within '.products-list .product' do
      click_on 'More Details…'
    end

    click_on 'Buy Now $10.00'

    fill_in 'order[credit_card_number]', with: '4111111111111111'
    fill_in 'order[expiration_month]', with: 12
    fill_in 'order[expiration_year]', with: 25
    fill_in 'order[shipping_name]', with: 'Pat Jones'
    fill_in 'order[address]', with: '123 Any St'
    fill_in 'order[zipcode]', with: 83_701
    fill_in 'order[child_full_name]', with: child.full_name
    fill_in 'order[child_birthdate]', with: child.birthdate.strftime('%Y-%m-%d')
    check 'order[as_gift]'
    fill_in 'order[child_parent_name]', with: child.parent_name

    click_on 'Purchase'

    expect(page).to have_content('Thanks for Your Order')
    expect(page).to have_content(Order.last.user_facing_id)
    expect(page).to have_content(child.full_name)
  end

  scenario 'Tells us when there was a problem charging our card' do
    visit '/'

    within '.products-list .product' do
      click_on 'More Details…'
    end

    click_on 'Buy Now $10.00'

    fill_in 'order[credit_card_number]', with: '4242424242424242'
    fill_in 'order[expiration_month]', with: 12
    fill_in 'order[expiration_year]', with: 25
    fill_in 'order[shipping_name]', with: 'Pat Jones'
    fill_in 'order[address]', with: '123 Any St'
    fill_in 'order[zipcode]', with: 83_701
    fill_in 'order[child_full_name]', with: 'Kim Jones'
    fill_in 'order[child_birthdate]', with: '2019-03-03'

    click_on 'Purchase'

    expect(page).not_to have_content('Thanks for Your Order')
    expect(page).to have_content('Problem with your order')
    expect(page).to have_content(Order.last.user_facing_id)
    expect(page).to have_content('Kim Jones')
  end
end
