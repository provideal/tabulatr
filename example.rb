require "ostruct"
require "table_builder"

@products = [
  OpenStruct.new({:idd => 1, :title => "Hund", :happy => 'no', :category_id => 1, :ping => 'pong'}),
  OpenStruct.new({:idd => 2, :title => "Katze", :happy => 'yes', :category_id => 1, :ping => 'ping'}),
  OpenStruct.new({:idd => 3, :title => "Maus", :happy => 'no', :category_id => 2, :ping => 'pong'}),
  OpenStruct.new({:idd => 4, :title => "Pferd", :happy => 'yes', :category_id => 2, :ping => 'ping'})
]


s = TableBuilder.build_table @products, :table_html => {:class => 'datagrid'} do |t|
  t.column :idd,          :header => 'Id', :type => 'integer'
  t.column :title,        :filter_match  => :like
  t.column :happy,        :filter => {"yes" => 1, "no" => 2}
  t.column :category_id,  :filter => false
  t.column :ping,         :header => 'Ping or Pong', :filter => ['ping', 'pong']
end

print s
