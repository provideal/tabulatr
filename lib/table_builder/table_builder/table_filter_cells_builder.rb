# Builder class to define the filter cells of a table
#
# Author::    Peter Horn, (mailto:peter.horn@provideal.net)
# Copyright:: Copyright (c) 2010 by Provideal Systems GmbH (http://www.provideal.net)
# License::   MIT, APACHE, Ruby, whatever, something free, ya know?
class TableBilder::TableFilterCellsBuilder < TableBilder::TableAbstractCellsBuilder
  # the method used to actually define the filters of the columns,
  # taking the name of the attribute and a hash of options.
  #
  # The following options are evaluated here:
  # <tt>:filter_html</tt>:: a hash with html-attributes added to the <ts>s created
  # <tt>:filter</tt>:: may take different values:
  #                    <tt>false</tt>:: no filter is output for this column
  #                    a Hash:: the keys of the hash are used to define a <tt>select</tt>
  #                             where the values are the <tt>value</tt> of the <tt>options</tt>.
  #                    an Array:: the elements of that array are used to define a
  #                               <tt>select</tt>
  #                    a subclass of <tt>ActiveRecord::Base</tt>:: a <tt>select</tt> is created
  #                                                                with all instances
  def column(name, opts={}, &block)
    opts = normalize_column_options opts
    @value << make_tag(:td, opts[:filter_html])
    v = if !opts[:filter]
      ""
    elsif opts[:filter].class == Hash
      opts[:filter].inject("<select name=\"filter[#{name}]\"><option value=""></option>") do |s,p|
        s << "<option value=\"#{p[1]}\">#{p[0]}</option>"
      end << "</select>"
    elsif opts[:filter].class == Array
      opts[:filter].inject("<select name=\"filter[#{name}]\">") do |s,p|
        s << "<option value=\"#{p}\">#{p}</option>"
      end << "</select>"
    elsif opts[:filter].class == Class
      # FIXME implement opts[:filter].all ...
      raise "Implement me: '#{opts[:filter]}'"
    else
      make_tag(:input, :type => :text, :name => "filter[#{name}]", :style => "width:98%") << "</input>"
    end
    @value << v 
    @value << "%<input type=\"hidden\" name=\"filter_matcher[#{name}]\" value=\"like\" />" if opts[:filter_like]
    @value << "</td>"
  end
end
