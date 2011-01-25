
# These are extensions for use from ActionController instances
# In a seperate class call only for clearity
module TableBuilder::TableOptions

  def self.get_table_options(params, opts={})
    val = {}
    val[:paginate] = PAGINATE_OPTIONS.merge(opts).merge(params[TABLE_FORM_OPTIONS[:paginate_name]] || {})
    val[:filter] = params[TABLE_FILTER_OPTIONS[:filter_name]].inject(["(1=1) ", []]) do |c, t|
      n, v = t
      # FIXME n = name_escaping(n)
      raise "SECURITY violation, field name is '#{n}'" unless /^[\d\w]+$/.match n 
      if (params["#{TABLE_FILTER_OPTIONS[:filter_name]}_matcher".to_sym] || {})[n]=='like'
        m = 'like'
        v = "%#{v}%"
      else m = '=' end
      [c[0] << "AND (`#{n}` #{m} ?) ", c[1] << v]
    end
    # FIXME escaping!!!
    val[:sort_by] = '...'
    val
  end

end

TableBuilder.send :include, TableBuilder::TableOptions
