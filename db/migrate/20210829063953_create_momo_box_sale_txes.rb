class CreateMomoBoxSaleTxes < ActiveRecord::Migration[6.1]
  def change
    create_table :momo_box_sale_txes do |t|
      t.integer :amount
      t.timestamp :crtime
      t.string :order_id
      t.bigint :price
      t.string :tx
      t.jsonb :payload

      t.timestamps

      t.index :tx, unique: true
    end
  end
end
