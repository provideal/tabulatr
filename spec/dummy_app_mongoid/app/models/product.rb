class Product
  include Mongoid::Document

  field :title,       :type => String
  field :price,       :type => Fixnum
  field :active,      :type => Boolean
  field :description, :type => String
  belongs_to :vendor, :autosave => true

end
