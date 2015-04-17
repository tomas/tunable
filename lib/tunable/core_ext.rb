require 'tunable/emoji_fix'

module Tunable

  module ActiveRecordExtensions

    def import(columns, values, options = {})
      if columns.length != values[0].length
        raise ArgumentError "Column and row lengths must match!"
      end

      columns_array = columns.map { |column| connection.quote_column_name(column) }

      values_array = values.map do |arr|
        row_values = []
        arr.each_with_index do |val, i|
          row_values << connection.quote(val)
        end
        row_values.join(',')
      end

      values_array = values_array.map{ |str| str.gsub(EmojiFix::REGEX, " ") }
      insert_method = options[:method] || 'INSERT'
      sql = "#{insert_method} INTO `#{self.table_name}` (#{columns_array.join(',')}) VALUES "

      # sqlite3 does not support multiple insert/replace,
      # so we need to generate a transaction with separate queries
      if ActiveRecord::Base.connection.adapter_name.downcase == 'sqlite'
        values_array.each do |vals|
          row_sql = "#{sql}(#{vals})"
          connection.execute(row_sql)
        end
      else
        sql += "(#{values_array.join('),(')})"
        connection.execute(sql)
      end
    end

  end

end
