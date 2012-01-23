class Tabulatr::Adapter::MongoidAdapter < Tabulatr::Adapter
  def primary_key
    :id
  end

  def key_type
    :string
  end

  def selected_ids(opts)
    preconditions_scope(opts).only(:id)
  end

  def table_name
    if Object.const_defined?("Mongoid") && @relation.is_a?(Mongoid::Criteria)
      @relation.klass
    else
      @relation
    end.to_s.tableize.gsub('/','_')
  end

  def table_name_for_association(assoc)
    assoc.to_s.tableize
  end

  def order_for_query(sortparam, default)
    context = order(sortparam, default)
    context.values.map(&:to_s) if context
  end

  def includes(includes)
    @relation   # do nothing with includes
  end

  def add_conditions_from(n,v)
    if v.is_a?(String)
      nn = n.split('.').last
      @relation = @relation.where(nn => v) unless v.blank?
    elsif v.is_a?(Hash)
      if v[:like].present?
        nn = n.split('.').last
        @relation = @relation.where(nn => Regexp.new(v[:like]))
      else
        nn = n.split('.').last.to_sym
        @relation = @relation.where(nn.gte => v[:from]) if v[:from].present?
        @relation = @relation.where(nn.lte => v[:to]) if v[:to].present?
      end
    else
      raise "Wrong filter type: #{v.class}"
    end

  end
end

