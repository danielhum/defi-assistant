class CreatePriceAlerts < ActiveRecord::Migration[6.1]
  def change
    create_table :price_alerts do |t|
      t.string :coin
      t.string :currency
      t.float :price
      t.float :last_price

      t.timestamps
    end
  end
end
