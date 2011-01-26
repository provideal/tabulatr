module TableBuilder::HeaderCell


  # the method used to actually define the headers of the columns,
  # taking the name of the attribute and a hash of options.
  #
  # The following options are evaluated here:
  # <tt>:th_html</tt>:: a hash with html-attributes added to the <th>s created
  # <tt>:header</tt>:: if present, the value will be output in the header cell,
  #                    otherwise, the capitalized name is used
  def header_column(name, opts={}, &block)
    raise "Not in header mode!" if @row_mode != :header
    opts = normalize_column_options opts
    if opts[:sortable] and @table_options[:sort]
      # change classes accordingly
    end
    make_tag(:th, opts[:th_html]) do
      concat(opts[:header] || name.to_s.capitalize)
    end # </th>
  end

  # the method used to actually define the headers of the columns,
  # taking the name of the attribute and a hash of options.
  #
  # The following options are evaluated here:
  # <tt>:th_html</tt>:: a hash with html-attributes added to the <th>s created
  # <tt>:header</tt>:: if present, the value will be output in the header cell,
  #                    otherwise, the capitalized name is used
  def header_association(relation, name, opts={}, &block)
    raise "Not in header mode!" if @row_mode != :header
    opts = normalize_column_options opts
    if opts[:sortable] and @table_options[:sort]
      # change classes accordingly
    end
    make_tag(:th, opts[:th_html]) do
      concat(opts[:header] || "#{relation.to_s.capitalize} #{name.to_s.capitalize}")
    end # </th>
  end

end

TableBuilder.send :include, TableBuilder::HeaderCell
