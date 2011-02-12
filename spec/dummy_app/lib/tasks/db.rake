# encoding: utf-8

namespace :db do

  def lorem(n=4)
    words = %w{lorem ipsum dolor sit amet consectetur adipisicing elit culpa officia deserunt mollit anim laborum}
    (1..n).inject("") { |s,i| s << " " << words[rand(words.length)] }.strip
  end

  task(:seed => :environment) do
    vendor_names = ["IBM Inc.", "Raclette", '37 Signal', "Aldi Nord"]
    4.times do |k|
      puts "Creating vendor #{k}"
      vendor = Vendor.new(:name => vendor_names[k], :active => true, 
        :url => "http://www.#{k}sadad.de", 
        :description => lorem(5+rand(10)))
      vendor.save!
    end

    tags = %w{news bugs moo foo bar rails unix tools}.map do |w|
      tag = Tag.new(:title => w)
      tag.save!
      tag
    end
    
    120.times do |k|
      puts "Creating product #{k}"
      name = lorem(3+rand(3))
      product = Product.new(:title => name, :active => (rand(2) == 0), :price => (rand*10).round(2), 
        :description => lorem(5+rand(10)))
      product.vendor = Vendor.find (k%4)+1
      product.save!
      rand(4).times do 
        product.tags << tags[rand(tags.length)]
      end
    end
    nil
  end

end