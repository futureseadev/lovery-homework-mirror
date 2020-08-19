class Order < ApplicationRecord
  belongs_to :product
  belongs_to :child, optional: true # allow for custom error message below

  validates :shipping_name, presence: true
  validates :child, presence: { message: 'not found with the provided information.' }

  def to_param
    user_facing_id
  end
end
