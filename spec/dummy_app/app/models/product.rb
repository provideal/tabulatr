class Product < ActiveRecord::Base

  has_and_belongs_to_many :tags
  belongs_to :vendor
  
end
