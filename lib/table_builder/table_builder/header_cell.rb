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
    sortparam = "#{@classname}#{TableBuilder::TABLE_FORM_OPTIONS[:sort_postfix]}"
    opts = normalize_column_options opts
    make_tag(:th, opts[:th_html]) do
      concat(opts[:header] || name.to_s.capitalize)
      if opts[:sortable] and @table_options[:sortable]
        if @sorting and @sorting[:by].to_s == name.to_s
          pname = "#{sortparam}[_resort][#{name}][#{@sorting[:direction] == 'asc' ? 'desc' : 'asc'}]" 
          psrc = TableBuilder::TABLE_DESIGN_OPTIONS[@sorting[:direction] == 'desc' ? 
            :sort_down_button : :sort_up_button]
          make_tag(:input, :type => :hidden, 
            :name => "#{sortparam}[#{name}][#{@sorting[:direction]}]", 
            :value => "#{@sorting[:direction]}")
        else
          pname = "#{sortparam}[_resort][#{name}][desc]"
          psrc = TableBuilder::TABLE_DESIGN_OPTIONS[:sort_down_button_inactive]
        end
        make_tag(:input, :type => 'image', 
          :src => psrc,
          :name => pname)
      end
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
