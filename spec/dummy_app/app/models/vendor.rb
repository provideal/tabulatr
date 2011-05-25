if USE_MONGOID
  class Vendor
    include Mongoid::Document

    has_many :products
    field :name,        :type => String
    field :url,         :type => String
    field :active,      :type => Boolean
    field :description, :type => String
    field :created_at,  :type => Time
    field :updated_at,  :type => Time
  end
else
  class Vendor < ActiveRecord::Base
    has_many :products
  end
end
