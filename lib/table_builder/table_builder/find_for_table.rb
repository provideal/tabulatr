
# These are extensions for use from ActionController instances
# In a seperate class call only for clearity
class TableBuilder

  def self.find_for_table(klaz, params, opts={})
    # firstly, get the conditions from the filters
    debugger
    cname = klaz.to_s.downcase
    filter_param = ({} || params["#{cname}#{TABLE_FORM_OPTIONS[:filter_postfix]}"])
    conditions = filter_param.inject(["(1=1) ", []]) do |c, t|
      n, v = t
      # FIXME n = name_escaping(n)
      raise "SECURITY violation, field name is '#{n}'" unless /^[\d\w]+$/.match n 
      if v.class == String
        [c[0] << "AND (`#{n}` = ?) ", c[1] << v]
      elsif v.class == Hash
        if v[:like]
          [c[0] << "AND (`#{n}` LIKE ?) ", c[1] << "%#{v[:like]}%"]
        elsif v[:from]
          [c[0] << "AND (`#{n}` > ? AND `#{n}` < ?) ", 
            c[1] << "#{v[:from]}" << "#{v[:to]}"]
        else 
          raise "whatsup? #{v.keys.to_s}"
        end
      else
        raise "Wrong filter type: #{w.class}"
      end
    end

    # secondly, find the order_by stuff
    # FIXME: Implement me! PLEEEZE!
    order_by = "id asc"

    # thirdly, get the pagination data
    paginate_options = PAGINATE_OPTIONS.merge(opts).
      merge(params["#{cname}#{TABLE_FORM_OPTIONS[:pagination_postfix]}"] || {})
    page = paginate_options[:page].to_i
    pagesize = paginate_options[:pagesize].to_f
    c = klaz.count :conditions => conditions
    pages = (c/pagesize).ceil
    page = [page, pages].min
    
    # Now, actually find the stuff
    found = klaz.find :all, :conditions => conditions, 
      :limit => pagesize, :offset => (page-1)*pagesize, 
      :order  => order_by
    # finally, inject a method to retrieve the current 'settings'

    found.define_singleton_method(FINDER_INJECT_OPTIONS[:pagination]) do 
      {:page => page, :pagesize => pagesize, :count => c, :pages => pages, :pagesizes => paginate_options[:pagesizes]} 
    end
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:filters]) do 
      filter_param
    end
    found.define_singleton_method(FINDER_INJECT_OPTIONS[:classname]) do 
      cname
    end
    
    found
  end

end
