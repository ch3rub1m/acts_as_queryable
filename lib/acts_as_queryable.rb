require "acts_as_queryable/version"

module ActsAsQueryable
  extend ActiveSupport::Concern

  module ClassMethods
    def acts_as_queryable(options = {})
      raise ArgumentError, "Hash expected, got #{options.class.name}" unless options.is_a?(Hash) || options.empty?
      except = options[:except] || []
      raise ArgumentError, "Array expected, got #{except.class.name}" unless except.class.name || options.empty?
      except.map! { |e| e.to_s }
      @query_param_names = self.attribute_names - except
      @order = options[:order]
    end

    def query(query_params)
      conditions = []
      params = []
      query_params.each do |key, value|
        key = key.to_s
        next unless self.columns_hash[key] && @query_param_names.include?(key)
        if value == 'NULL'
          conditions << "#{key} IS NULL"
          next
        end
        case self.columns_hash[key].type
        when :string, :text
          conditions << "#{key} LIKE ?"
          params << "%#{value}%"
        when :integer
          sub_conditions = []
          value.split(',').each do |integer|
            sub_conditions << "#{key} = #{integer}"
            params << integer
          end
          conditions << "(#{sub_conditions.join(' OR ')})"
        else
          conditions << "#{key} = ?"
          params << value
        end
      end
      query_params.each do |key, value|
        key = key.to_s
        suffix = suffix(key)
        key = remove_suffix(key)
        next unless self.columns_hash[key]
        case self.columns_hash[key].type
        when :integer, :float, :datetime
          case suffix
          when 'gt'
            conditions << "#{key} > ?"
            params << value
          when 'lt'
            conditions << "#{key} < ?"
            params << value
          end
        end
      end
      query = conditions.join(' AND ')
      self.where(query, params).order(@order && query_params[:order])
    end

    private
      def remove_suffix(string)
        suffix_length = suffix(string).length + 1
        string.slice(0...string.length - suffix_length)
      end

      def suffix(string)
        string.split('_').last
      end
  end
end

ActiveRecord::Base.send :include, ActsAsQueryable
