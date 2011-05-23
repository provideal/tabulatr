if USE_MONGOID
  class Tag
    include Mongoid::Document
    field :title, :type => String
    has_and_belongs_to_many :products
  end
else
  class Tag < ActiveRecord::Base
    has_and_belongs_to_many :products
  end
end