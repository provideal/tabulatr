class Tabulatr::Adapter::ActiveRecordAdapter < Tabulatr::Adapter

  def initialize(klaz)
    set_like_statement unless Tabulatr::SQL_OPTIONS[:like]

    super klaz
  end

  def primary_key
    @relation.primary_key.to_sym
  end

  def key_type
    @relation.columns_hash[primary_key.to_s].type
  end

  def selected_ids(opts)
    preconditions_scope(opts).select(:id)
  end

  def table_name
    @relation.table_name
  end

  def table_name_for_association(assoc)
    @base.reflect_on_association(assoc).table_name
  end

  def order_for_query(sortparam, default)
    context = order(sortparam, default)
    "#{context[:by]} #{context[:direction]}" if context
  end

  def includes(inc)
    @relation.includes(inc)
  end

  def includes!(inc)
    @relation = includes(includes)
  end

  def add_conditions_from(n,v)
    like ||= Tabulatr.sql_options[:like]
    if v.is_a?(String)
      @relation = @relation.where(n => v) unless v.blank?
    elsif v.is_a?(Hash)
      if v[:like].present?
        @relation = @relation.where("#{n} #{like} ?", "%#{v[:like]}%")
      else
        @relation = @relation.where("#{n} >= ?", "#{v[:from]}") if v[:from].present?
        @relation = @relation.where("#{n} <= ?", "#{v[:to]}") if v[:to].present?
      end
    else
      raise "Wrong filter type: #{v.class}"
    end
  end

  private
  def set_like_statement
    case ActiveRecord::Base.connection.class.to_s
      when "ActiveRecord::ConnectionAdapters::MysqlAdapter" then Tabulatr.sql_options(:like => 'LIKE')
      when "ActiveRecord::ConnectionAdapters::Mysql2Adapter" then Tabulatr.sql_options(:like => 'LIKE')
      when "ActiveRecord::ConnectionAdapters::PostgreSQLAdapter" then Tabulatr.sql_options(:like => 'ILIKE')
      when "ActiveRecord::ConnectionAdapters::SQLiteAdapter" then Tabulatr.sql_options(:like => 'LIKE')
      when "ActiveRecord::ConnectionAdapters::SQLite3Adapter" then Tabulatr.sql_options(:like => 'LIKE')
      else
        warn("Tabulatr Warning: Don't know which LIKE operator to use for the ConnectionAdapter '#{ActiveRecord::Base.connection.class}'.\n" +
          "Please specify by `Tabulatr.sql_options(:like => '<likeoperator>')`")
        Tabulatr.sql_options(:like => 'LIKE')
    end
  end
end
