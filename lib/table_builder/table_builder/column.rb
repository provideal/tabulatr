module TableBuilder::Column
  # the method used to actually define the data cells of the columns,
  # taking the name of the attribute and a hash of options.
  #
  # The following options are evaluated here:
  # <tt>:td_html</tt>:: a hash with html-attributes added to the <ts>s created
  # <tt>:method</tt>:: the actual method invoked on the record to retrieve the
  #                    value for the column, or false if name is to be used.
  # <tt>:fromat</tt>:: either a String by which the value is <tt>sprinf</tt>ed,
  #                    a proc/lambda to which the value is passed or false if
  #                    no specific formatting is desired.
  def data_column(name, opts={}, &block)
    raise "Not in data mode!" if @row_mode != :data
    opts = normalize_column_options opts
    make_tag(:td, opts[:td_html]) do
      if block_given?
        yield(@record)
      else
        val = @record.send(opts[:method] || name)
        val = opts[:format].call(val) if opts[:format].class == Proc
        val = (opts[:format] % val)   if opts[:format].class == String
        concat(val.to_s)
      end # block_given?
    end # </td>
  end

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
  def filter_column(name, opts={}, &block)
    raise "Not in filter mode!" if @row_mode != :filter
    opts = normalize_column_options(opts)
    make_tag(:td, opts[:filter_html]) do
      of = opts[:filter]
      if !of
        ""
      elsif of.class == Hash
        make_tag(:select, :name => "filter[#{name}]") do 
          # TODO: make this nicer
          option_
          concat("<option></option>") 
          of.each do |t,v|
            make_tag(:option, :value => t) do
              concat v
            end # </option>
          end # each
        end # </select>
      elsif opts[:filter].class == Array
        # TODO: make this nicer
        concat("<option></option>") 
        of.each do |p|
          make_tag(:option, :value => p) do
            concat p
          end # </option>
        end # each
      elsif opts[:filter].class == Class
        # FIXME implement opts[:filter].all ...
        raise "Implement me: '#{opts[:filter]}'"
      else
        make_tag(:input, :type => :text, :name => "#{}_#{TABLE_DESIGN_OPTIONS[:filter_postfix]}[#{name}]", :style => "width:98%")
      end # if
      make_tag(:input, :type => :hidden, :name => "filter_matcher[#{name}]", :value => "like") if opts[:filter_like]
    end # </td>
  end
end

TableBuilder.send :include, TableBuilder::Column