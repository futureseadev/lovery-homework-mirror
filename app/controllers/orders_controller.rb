class OrdersController < ApplicationController
  def new
    @order = Order.new(product: Product.find(params[:product_id]))
  end

  def create
    @order = create_order

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
    params.require(:order).permit(:shipping_name, :product_id, :zipcode, :address, :message).merge(paid: false)
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
      Child.includes(:orders).find_by(gifted_child_params)
    else
      Child.find_or_create_by(child_params)
    end
  end

  def create_order
    if gifting?
      order = child&.orders&.last
      Order.create(order_params.merge(child: child, address: order&.address, zipcode: order&.zipcode))
    else
      Order.create(order_params.merge(child: child))
    end
  end
end
