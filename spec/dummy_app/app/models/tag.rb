if USE_MONGOID
  class Tag
    include Mongoid::Document
    has_and_belongs_to_many :products
    field :title, :type => String
    field :created_at,  :type => Time
    field :updated_at,  :type => Time
  end
else
  class Tag < ActiveRecord::Base
    has_and_belongs_to_many :products
  end
end