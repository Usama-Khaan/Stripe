class ChargesController < ApplicationController
  rescue_from Stripe::CardError, Stripe::InvalidRequestError, with: :catch_exception

  before_action :set_params, only: [:create]
  before_action :find_book, only: [:create, :new]

  def new; end

  def create
    # Now create the charge using the price created above
    charge = Stripe::Charge.create(
      amount: (@book.price * 100).to_i,
      source: params[:stripeToken],
      currency: 'usd'
    )

    flash[:notice] = charge[:paid] ? success_message(charge) : failure_message
    redirect_to root_path
  end

  private

  def find_book
    @book = Book.find(params[:book_id])
  end

  def set_params
    @card_number = params[:card_number] || 0
    @card_month = params[:month] || 0
    @card_year = params[:year] || 0
    @cvc = params[:cvc] || 0
    @amount = params[:amount]&.to_i || 0
  end

  def catch_exception(exception)
    flash[:alert] = exception.message
    redirect_back fallback_location: root_path
  end

  def success_message(charge)
    "Your payment of amount: #{@amount} has been successfully processed."
  end

  def failure_message
    "We are sorry. We are unable to proceed with your request. Please try again later."
  end
end
