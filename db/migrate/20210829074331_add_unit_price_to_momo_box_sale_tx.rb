class AddUnitPriceToMomoBoxSaleTx < ActiveRecord::Migration[6.1]
  def change
    add_column :momo_box_sale_txes, :unit_price, :decimal
  end
end
