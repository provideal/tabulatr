#--
# Monkey Patching...
#--


require 'table_builder/table_builder'

class ActionView::Base
  # render the table in a view
  def table_for(records, opts={}, &block)
    table_builder = TableBuilder.new(records, self, opts)
    table_builder.build_table(&block)# von concat , block.binding
  end
end

class ActionController::Base
  # get the correct settings from the current params hash
  def get_table_options(opts={})
    val = TableBuilder.get_table_options(opts, params)
    @page = val[:paginate][:page]
    @per_page = val[:paginate][:per_page]
    @filter = val[:filter]
    @sort_by = val[:sort_by]
  end
end
