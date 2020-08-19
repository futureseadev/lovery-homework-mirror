class OrdersController < ApplicationController
  def new
    @order = Order.new(product: Product.find(params[:product_id]))
  end

  def create
    @order = Order.create(order_params.merge(child: child, user_facing_id: SecureRandom.uuid[0..7]))

    if @order.valid?
      Purchaser.new.purchase(@order, credit_card_params)
      redirect_to order_path(@order)
    else
      render :new
    end
  end

  def show
    @order = Order.find_by(id: params[:id]) || Order.find_by(user_facing_id: params[:id])
  end

  private

  def order_params
    params.require(:order).permit(:shipping_name, :product_id, :zipcode, :address).merge(paid: false)
  end

  def child_params
    {
      full_name: params.require(:order)[:child_full_name],
      parent_name: params.require(:order)[:shipping_name],
      birthdate: Date.parse(params.require(:order)[:child_birthdate])
    }
  end

  def gifted_child_params
    {
      full_name: params.require(:order)[:child_full_name],
      parent_name: params.require(:order)[:child_parent_name],
      birthdate: Date.parse(params.require(:order)[:child_birthdate])
    }
  end

  def credit_card_params
    params.require(:order).permit(:credit_card_number, :expiration_month, :expiration_year)
  end

  def gifting?
    params.require(:order)[:as_gift] != '0'
  end

  def child
    if gifting?
      Child.find_by(gifted_child_params)
    else
      Child.find_or_create_by(child_params)
    end
  end
end
