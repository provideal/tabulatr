class CreateVendors < ActiveRecord::Migration
  def self.up
    create_table :vendors do |t|
      t.integer :id
      t.string :name
      t.string :url
      t.boolean :active
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :vendors
  end
end
