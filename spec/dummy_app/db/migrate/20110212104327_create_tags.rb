class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :title
      t.timestamps
    end

    create_table :products_tags, :id => false do |t|
      t.belongs_to :tag
      t.belongs_to :product
    end

  end


  def self.down
    drop_table :tags
  end
end
