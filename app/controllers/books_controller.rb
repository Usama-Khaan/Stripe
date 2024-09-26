class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy ]

  # GET /books or /books.json
  def index
    @books = Book.all
  end

  # GET /books/1 or /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books or /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        create_stripe_product(@book)
        format.html { redirect_to @book, notice: "Book was successfully created." }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1 or /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        update_stripe_price(@book)  # Update the price on Stripe when the book is updated
        format.html { redirect_to @book, notice: "Book was successfully updated." }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1 or /books/1.json
  def destroy
    Stripe::Product.update(@book.stripe_product_id, { active: false })

    @book.destroy!

    respond_to do |format|
      format.html { redirect_to books_path, status: :see_other, notice: "Book was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_book
      @book = Book.find(params[:id])
    end

    def book_params
      params.require(:book).permit(:title, :author, :price, :description)
    end

    def create_stripe_product(book)
      product = Stripe::Product.create({
        name: book.title,
        description: book.description
      })

      Stripe::Price.create({
        unit_amount: (book.price * 100).to_i,
        currency: 'usd',
        product: product.id
      })

      book.update(stripe_product_id: product.id)
    rescue Stripe::StripeError => e
      flash[:alert] = "Stripe error: #{e.message}"
    end

    def update_stripe_price(book)
      return unless book.stripe_product_id

      prices = Stripe::Price.list(product: book.stripe_product_id, active: true)

      prices.data.each do |price|
        Stripe::Price.update(price.id, { active: false })
      end

      Stripe::Price.create({
        unit_amount: (book.price * 100).to_i,
        currency: 'usd',
        product: book.stripe_product_id
      })
    rescue Stripe::StripeError => e
      flash[:alert] = "Stripe error: #{e.message}"
    end
end
