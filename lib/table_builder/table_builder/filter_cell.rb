module TableBuilder::FilterCell

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
          #option_
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
      elsif opts[:filter] == :range
        make_tag(:input, :type => :text, :name => "#{TableBuilder::TABLE_FORM_OPTIONS[:filter_name]}[#{name}][from]", :style => "width:#{opts[:filter_width]}")
        concat(opts[:range_filter_symbol])
        make_tag(:input, :type => :text, :name => "#{TableBuilder::TABLE_FORM_OPTIONS[:filter_name]}[#{name}][to]", :style => "width:#{opts[:filter_width]}")
      else
        make_tag(:input, :type => :text, :name => "#{TableBuilder::TABLE_FORM_OPTIONS[:filter_name]}[#{name}]", :style => "width:#{opts[:filter_width]}")
      end # if
      make_tag(:input, :type => :hidden, :name => "filter_matcher[#{name}]", :value => "like") if opts[:filter_like]
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
    filter_column(relation, opts, &block)
    # opts = normalize_column_options(opts)
    # make_tag(:td, opts[:filter_html]) do
      # of = opts[:filter]
      # if !of
      #   ""
      # elsif of.class == Hash
      #   make_tag(:select, :name => "filter[#{name}]") do 
      #     # TODO: make this nicer
      #     concat("<option></option>") 
      #     of.each do |t,v|
      #       make_tag(:option, :value => v) do
      #         concat t
      #       end # </option>
      #     end # each
      #   end # </select>
      # elsif opts[:filter].class == Array
      #   # TODO: make this nicer
      #   concat("<option></option>") 
      #   of.each do |p|
      #     make_tag(:option, :value => p) do
      #       concat p
      #     end # </option>
      #   end # each
      # elsif opts[:filter].class == Class
      #   # FIXME implement opts[:filter].all ...
      #   raise "Implement me: '#{opts[:filter]}'"
      # else
      #   make_tag(:input, :type => :text, :name => "filter[#{name}]", :style => "width:98%")
      # end # if
      # make_tag(:input, :type => hidden, :name => "filter_matcher[#{name}]", :value => "like") if opts[:filter_like]
    # end # </td>
  end

end

TableBuilder.send :include, TableBuilder::FilterCell
