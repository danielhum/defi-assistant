class CreateMomoListings < ActiveRecord::Migration[6.1]
  def change
    create_table :momo_listings do |t|
      t.string :tx
      t.string :token_id
      t.bigint :start_price
      t.bigint :now_price
      t.bigint :end_price
      t.integer :specialty
      t.integer :quality
      t.integer :lv_hashrate
      t.integer :level
      t.integer :index
      t.string :raw_id
      t.integer :hashrate
      t.integer :duration_days
      t.integer :category
      t.string :auctor
      t.integer :uptime
      t.jsonb :payload

      t.timestamps

      t.index :raw_id, unique: true
    end
  end
end
