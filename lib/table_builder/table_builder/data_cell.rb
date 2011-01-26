module TableBuilder::DataCell

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
  def data_association(relation, name, opts={}, &block)
    raise "Not in data mode!" if @row_mode != :data
    opts = normalize_column_options opts
    if block_given?
      return yield(@record)
    end
    assoc = @record.class.reflect_on_association(relation)
    make_tag(:td, opts[:td_html]) do
      concat(if [:has_many, :has_and_belongs_to_many].member? assoc.macro
        @record.send relation
      else
        [ @record.send(relation.to_sym) ]
      end.map do |r|
        val = r.send(opts[:method] || name)
        val = opts[:format].call(val) if opts[:format].class == Proc
        val = (opts[:format] % val)   if opts[:format].class == String
        val
      end.join(opts[:join_symbol]))
    end # </td>
  end

end

TableBuilder.send :include, TableBuilder::DataCell
