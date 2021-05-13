class AddStripePriceIdToPlans < ActiveRecord::Migration[6.1]
  def change
    add_column :plans, :stripe_price_id, :string
  end
end
