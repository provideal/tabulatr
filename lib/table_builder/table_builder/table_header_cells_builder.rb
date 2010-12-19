# Builder class to define the header cells of a table
#
# Author::    Peter Horn, (mailto:peter.horn@provideal.net)
# Copyright:: Copyright (c) 2010 by Provideal Systems GmbH (http://www.provideal.net)
# License::   MIT, APACHE, Ruby, whatever, something free, ya know?
class TableBilder::TableHeaderCellsBuilder < TableBilder::TableAbstractCellsBuilder
  # the method used to actually define the headers of the columns,
  # taking the name of the attribute and a hash of options.
  #
  # The following options are evaluated here:
  # <tt>:th_html</tt>:: a hash with html-attributes added to the <th>s created
  # <tt>:header</tt>:: if present, the value will be output in the header cell,
  #                    otherwise, the capitalized name is used
  def column(name, opts={}, &block)
    opts = normalize_column_options opts
    if opts[:sortable] and @opts[:sort]
      # change classes accordingly
    end
    if @opts[:batch_actions] 
      @value << make_tag(:th, opts[:th_html]) << "</th>"
    end
    @value << make_tag(:th, opts[:th_html]) << (opts[:header] || name.to_s.capitalize) 
    @value << "</th>"
  end
end

