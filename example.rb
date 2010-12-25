require "ostruct"
require "table_builder"

@products = [
  OpenStruct.new({:idd => 1, :title => "Hund", :happy => 'no', :category_id => 1, :ping => 'pong'}),
  OpenStruct.new({:idd => 2, :title => "Katze", :happy => 'yes', :category_id => 1, :ping => 'ping'}),
  OpenStruct.new({:idd => 3, :title => "Maus", :happy => 'no', :category_id => 2, :ping => 'pong'}),
  OpenStruct.new({:idd => 4, :title => "Pferd", :happy => 'yes', :category_id => 2, :ping => 'ping'})
]


build_table @products, :table_html => {:class => 'datagrid'} do |t|
  h = {:idd => {:header => 'Id', :type => 'integer'}, ...}
  h.each do |k,v| t.column k, v end
    
  t.column :idd,          :header => 'Id', :type => 'integer'
  t.column :title,        :filter_match  => :like, :method => :full_title
  t.column :happy,        :filter => {"yes" => 1, "no" => 2}
  t.column :category_id,  :filter => false
  t.column :ping,         :header => 'Ping or Pong', :filter => ['ping', 'pong']
  t.column :price,        :format => proc {|x| ... }
  t.column :action,       :header => "Action", :filter => false do |p|
    "link_to edit for '#{p.title}'"
  end
end

print s
