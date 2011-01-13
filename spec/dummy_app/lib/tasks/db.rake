# encoding: utf-8

namespace :db do

  desc "blah blah"

  task(:seed => :environment) do
    4.times do |k|
      puts "Creating vendor #{k}"
      vendor = Vendor.new(:name => "Vendor #{k}", :active => true, :url => "http://www.#{k}sadad.de", :description => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.')
      vendor.save!
    end
    
    120.times do |k|
      puts "Creating product #{k}"
      product = Product.new(:title => "Product #{k}", :active => true, :price => (rand*10).round(2), :description => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.')
      product.vendor = Vendor.find (k%4)+1
      product.save!
    end
    
    
    nil
  end

end