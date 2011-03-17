class CreateProducts < ActiveRecord::Migration
  def self.up
    create_table :products do |t|
      t.belongs_to :vendor
      t.integer :id
      t.string :title
      t.decimal :price
      t.boolean :active
      t.text :description
      t.timestamps
    end
  end

  def self.down
    drop_table :products
  end
end
