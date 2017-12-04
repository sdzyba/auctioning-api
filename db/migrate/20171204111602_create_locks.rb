class CreateLocks < ActiveRecord::Migration[5.1]
  def change
    create_table :locks do |t|
      t.string :entity, null: false

      t.timestamps
    end

    add_index :locks, :entity, unique: true
  end
end
