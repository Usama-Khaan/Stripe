class AddStripeProductIdToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :stripe_product_id, :string
  end
end
