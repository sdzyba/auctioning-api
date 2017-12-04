class CreateAuctions < ActiveRecord::Migration[5.1]
  def change
    create_table :auctions do |t|
      t.decimal :price_current, precision: 10, scale: 2, null: false
      t.decimal :price_limit, precision: 10, scale: 2, null: false
      t.integer :step_current, null: false
      t.integer :step_limit, null: false
      t.string :status, null: false
      t.datetime :ride_at, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.belongs_to :driver

      t.timestamps
    end

    add_index :auctions, :start_at, unique: true
  end
end
