class Vendor
  include Mongoid::Document

  field :name,        :type => String
  field :url,         :type => String
  field :active,      :type => Boolean
  field :description, :type => String
  has_many :products, :autosave => true

end
