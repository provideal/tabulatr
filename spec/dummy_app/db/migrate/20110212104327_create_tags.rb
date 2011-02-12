class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :title

      t.timestamps
    end
    
    create_table :products_tags, :id => false do |t|
      t.integer :tag_id
      t.integer :product_id
    end
    
  end


  def self.down
    drop_table :tags
  end
end
