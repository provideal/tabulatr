require 'spec_helper'

describe "Tabulatrs" do

  names = %w{lorem ipsum dolor sit amet consectetur adipisicing elit sed eiusmod tempor incididunt labore dolore magna aliqua enim minim veniam, quis nostrud exercitation ullamco laboris nisi aliquip commodo consequat duis aute irure dolor reprehenderit voluptate velit esse cillum dolore fugiat nulla pariatur excepteur sint occaecat cupidatat non proident sunt culpa qui officia deserunt mollit anim est laborum}

  vendor1 = Vendor.create!(:name => "ven d'or", :active => true)
  vendor2 = Vendor.create!(:name => 'producer', :active => true)
  tag1 = Tag.create!(:title => 'foo')
  tag2 = Tag.create!(:title => 'bar')
  tag3 = Tag.create!(:title => 'fubar')
  name

  describe "GET /index_simple" do
    it "works in general" do
      get index_simple_products_path
      response.status.should be(200)
    end

    it "contains buttons" do
      visit index_simple_products_path
      [:submit_label, :select_all_label, :select_none_label, :select_visible_label,
        :unselect_visible_label, :select_filtered_label, :unselect_filtered_label
      ].each do |n|
        page.should have_button(Tabulatr::TABLE_OPTIONS[n])
      end
    end

    it "contains column headers" do
      visit index_simple_products_path
      ['Id','Title','Price','Active','Vendor Name','Tags Title'].each do |n|
        page.should have_content(n)
      end
    end

    it "contains other elements" do
      visit index_simple_products_path
      page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 0, 0, 0, 0))
    end

    it "contains the actual data" do
      product = Product.create!(:title => 'Fred', :active => true, :price => 10.0, :description => 'blah blah', :vendor => vendor1)
      visit index_simple_products_path
      page.should have_content("Fred")
      page.should have_content("true")
      page.should have_content("10.0")
      page.should have_content("ven d'or")
      page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 1, 1, 0, 1))
    end

    it "contains the actual data multiple" do
      9.times do |i|
        product = Product.create!(:title => names[i], :active => i.even?, :price => 11.0+i, 
          :description => "blah blah #{i}", :vendor => i.even? ? vendor1 : vendor2)
        visit index_simple_products_path
        page.should have_content(names[i])
        page.should have_content((11.0+i).to_s)
        page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], i+2, i+2, 0, i+2))
      end
    end

    it "contains the further data on the further pages" do
      names.each_with_index do |n,i|
        product = Product.create!(:title => n, :active => i.even?, :price => 30.0+i, 
          :description => "blah blah #{i}", :vendor => i.even? ? vendor1 : vendor2)
        visit index_simple_products_path
        page.should_not have_content((30.0+i).to_s)
        page.should have_content(sprintf(Tabulatr::TABLE_OPTIONS[:info_text], 10, i+11, 0, i+11))
      end
    end


  end

  describe "GET /products empty" do
    it "works in general" do
      get products_path
      response.status.should be(200)
    end
  end


end





