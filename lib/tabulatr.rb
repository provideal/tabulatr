#--
# Monkey Patching...
#--

require 'tabulatr/tabulatr'

class ActionView::Base
  # render the table in a view
  def table_for(records, opts={}, &block)
    tabulatr = Tabulatr.new(records, self, opts)
    tabulatr.build_table(&block)# von concat , block.binding
  end
end

class ActionController::Base
  # get the correct settings from the current params hash
  def get_table_options(opts={})
    val = Tabulatr.get_table_options(opts, params)
    @page = val[:paginate][:page]
    @pagesize = val[:paginate][:pagesize]
    @filter = val[:filter]
    @sort_by = val[:sort_by]
  end
end

if Object.const_defined? "ActiveRecord"
  class ActiveRecord::Base
    def self.find_for_table(params, opts={})
      Tabulatr.find_for_active_record_table(self, params, opts)
    end
  end
end

if Object.const_defined? "Mongoid"
  class Mongoid::Document
    def self.find_for_table(params, opts={})
      Tabulatr.find_for_mongoid_table(self, params, opts)
    end
  end
end

