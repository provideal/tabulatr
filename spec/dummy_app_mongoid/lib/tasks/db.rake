# encoding: utf-8

namespace :db do

  words = %w{lorem ipsum dolor sit amet consectetur adipisicing elit culpa officia deserunt mollit anim laborum}
  desc "blah blah"

  task(:seed => :environment) do
    vendors = [1,2,3,4].map do |k|
      puts "Creating vendor #{k}"
      vendor = Vendor.new(:name => "Vendor #{k}", :active => true, :url => "http://www.#{k}sadad.de", :description => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.')
      vendor.save!
      vendor
    end

    120.times do |k|
      puts "Creating product #{k}"
      name = (1..4).inject("") { |s,i| s << " " << words[rand(words.length)] }.strip << " #{k}"
      product = Product.new(:title => name, :active => (rand(2) == 0), :price => (rand*10).round(2), :description => 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.')
      product.vendor = vendors[k%4]
      product.vendor.save!
      product.save!
    end
    nil
  end

end