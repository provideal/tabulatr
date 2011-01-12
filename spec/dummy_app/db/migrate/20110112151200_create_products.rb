class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.integer :id
      t.string :title
      t.decimal :price
      t.boolean :active
      t.text :description
      t.integer :vendor_id

      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
