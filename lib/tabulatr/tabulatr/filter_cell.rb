module Tabulatr::FilterCell

  # the method used to actually define the filters of the columns,
  # taking the name of the attribute and a hash of options.
  #
  # The following options are evaluated here:
  # <tt>:filter_html</tt>:: a hash with html-attributes added to the <ts>s created
  # <tt>:filter</tt>:: may take different values:
  #                    <tt>false</tt>:: no filter is output for this column
  #                    a container:: the keys of the hash are used to define a <tt>select</tt>
  #                             where the values are the <tt>value</tt> of the <tt>options</tt>.
  #                    an Array:: the elements of that array are used to define a
  #                               <tt>select</tt>
  #                    a String:: a <tt>select</tt> is created with that String as options
  #                               you can use ActionView#collection_select and the like
  def filter_column(name, opts={}, &block)
    raise "Not in filter mode!" if @row_mode != :filter
    opts = normalize_column_options(opts)
    value = @filters[name]
    make_tag(:td, opts[:filter_html]) do
      of = opts[:filter]
      iname = "#{@classname}#{Tabulatr::TABLE_FORM_OPTIONS[:filter_postfix]}[#{name}]"
      filter_tag(of, iname, value, opts)
    end # </td>
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
  def filter_association(relation, name, opts={}, &block)
    raise "Not in filter mode!" if @row_mode != :filter
    opts = normalize_column_options(opts)
    filters = (@filters[Tabulatr::TABLE_FORM_OPTIONS[:associations_filter]] || {})
    value = filters["#{relation}.#{name}"]
    make_tag(:td, opts[:filter_html]) do
      of = opts[:filter]
      iname = "#{@classname}#{Tabulatr::TABLE_FORM_OPTIONS[:filter_postfix]}[#{Tabulatr::TABLE_FORM_OPTIONS[:associations_filter]}][#{relation}.#{name}]"
      filter_tag(of, iname, value, opts)
    end # </td>
  end

  def filter_checkbox(opts={}, &block)
    raise "Whatever that's for!" if block_given?
    make_tag(:td, opts[:filter_html]) do
      iname = "#{@classname}#{Tabulatr::TABLE_FORM_OPTIONS[:checked_postfix]}"
      make_tag(:input, :type => 'hidden', :name => "#{iname}[checked_ids]", :value => @checked[:checked_ids])
      make_tag(:input, :type => 'hidden', :name => "#{iname}[visible]", :value => @checked[:visible])
    end
  end

private

  def filter_tag(of, iname, value, opts)
    if !of
      ""
    elsif of.class == Hash or of.class == Array or of.class == String
      make_tag(:select, :name => iname) do
        if of.class == String
          concat(of)
        else
          concat("<option></option>")
          t = options_for_select(of)
          concat(t.sub("value=\"#{value}\"", "value=\"#{value}\" selected=\"selected\""))
        end
      end # </select>
    elsif opts[:filter] == :range
      make_tag(:input, :type => :text, :name => "#{iname}[from]",
        :style => "width:#{opts[:filter_width]}",
        :value => value ? value[:from] : '')
      concat(opts[:range_filter_symbol])
      make_tag(:input, :type => :text, :name => "#{iname}[to]",
        :style => "width:#{opts[:filter_width]}",
        :value => value ? value[:to] : '')
    elsif opts[:filter] == :checkbox
      checkbox_value = opts[:checkbox_value]
      checkbox_label = opts[:checkbox_label]
      concat(check_box_tag(iname, checkbox_value, false, {}))
      concat(checkbox_label)
    elsif opts[:filter] == :like
      make_tag(:input, :type => :text, :name => "#{iname}[like]",
        :style => "width:#{opts[:filter_width]}",
        :value => value ? value[:like] : '')
    else
      make_tag(:input, :type => :text, :name => "#{iname}", :style => "width:#{opts[:filter_width]}",
        :value => value)
    end # if
  end

end

Tabulatr.send :include, Tabulatr::FilterCell
