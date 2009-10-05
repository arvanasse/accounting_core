module InactiveRecord
  class InactiveRecordError < StandardError; end
  class RecordNotFound < InactiveRecordError; end
  
  class Base
    attr_reader :id
    attr_reader :attributes
    
    class_inheritable_hash :store
    class_inheritable_hash :columns    
    class << self
      def create(*args)
        options = args.extract_options!
        write_record(options)
      end
      
      def count
        get_records.size
      end
      
      def find(*args)
        options = args.extract_options!
        query_key = args.first unless args.empty?
        
        case 
          when query_key == :all    then find_every(options)
          when query_key == :first  then find_one(options)
          else                      find_from_keys(query_key)
        end
      end
      
      def all
        get_records.collect{|record_id, attr| new(record_id, attr)}
      end
      
      def create_table
        table_definition = InactiveRecord::Schema::TableDefinition.new(self)
        yield table_definition
      end
      
      def add_column(col)
        cols = read_inheritable_attribute(:columns) || {}
        cols[col.name] = col
        write_inheritable_attribute(:columns, cols)
      end
            
      def default_attributes
        read_inheritable_attribute(:columns).inject({}) do |attrs, col_info|
          column_id, definition = col_info
          attrs.merge(column_id=>definition.default)
        end
      end
      
      
      def write_record(*args)
        options = args.extract_options!
        raise(ArgumentError, "One or more attributes has the wrong data type") unless new(options).validate
        records = get_records
        record_id = args.empty? ? new_record_id : args.first
        records[record_id] = options
        write_inheritable_attribute(:store, records)
        return new(record_id, options)
      end
      
      def destroy(keys)
        keys = make_array(keys)
        records = get_records
        deleted_records = keys.inject([]) do |destroyed, key|
          if records[key]
            removed = new(key, records.delete(key)).freeze
            destroyed.push(removed) 
          end
        end
        write_inheritable_attribute(:store, records)
        keys.size==1 ? deleted_records.first : deleted_records
      end
      
      private
      def find_from_keys(keys)
        keys = make_array(keys)
        records = keys.collect{|record_id| read_record_by_id(record_id)}
        case keys.size
          when 0 then raise(InactiveRecord::RecordNotFound, "Could not find a record without an id")
          when 1 then records.first
          else   records
        end
      end
      
      def find_one(options={})
        filtered = filter_records(all, options.delete(:conditions))
        sorted = sort_records(filtered, options.delete(:order))
        sorted.first
      end
      
      def find_every(options={})
        filtered = filter_records(all, options.delete(:conditions))
        sorted = sort_records(filtered, options.delete(:order))
      end
      
      def sort_records(records, sort_keys)
        sort_keys = make_array(sort_keys)
        records.sort do |a, b|
          sort_keys.inject(0) do |equality, sort_key|
            equality.zero? ? a.attributes[sort_key] <=> b.attributes[sort_key] : equality
          end
        end
      end
      
      def filter_records(records, conditions)
        conditions ||= {}
        records.select do |record|
          conditions.inject(true) do |selected, condition|
            attr, match = condition
            value = record.attributes[attr]
            attribute_matched = match.respond_to?(:include?) ? match.include?(value) : value==match
            selected && attribute_matched
          end
        end
      end
      
      def read_record_by_id(record_id)
        raise(InactiveRecord::RecordNotFound, "No record with ID #{record_id}") unless record = get_records[record_id]
        new(record_id, record) 
      end
      
      def new_record_id(options={})
        records = get_records
        options.delete(:id) || calculate_next_id
      end
      
      def calculate_next_id
        records = get_records
        return 1 if records.empty?
        records.keys.max+1
      end
      
      def get_records
        read_inheritable_attribute(:store) || {}
      end
      
      def make_array(option)
        [option].flatten.compact
      end
    end
    
    def initialize(*args)
      attrs = args.extract_options!
      @id = args.first unless args.empty?
      @attributes = self.class.default_attributes.merge(attrs)
    end
    
    def validate
      cols = self.class.columns
      @attributes.inject(true) do |valid, attribute_info|
        attr_id, attr_val = attribute_info
        valid && cols[attr_id].correct_data_type?(attr_val)
      end
    end
    
    def save
      raise(ArgumentError, "One or more attributes has the wrong data type") unless validate
      self.class.write_record(@id, @attributes)
    end
    
    def destroy
      self.class.destroy(@id)
    end
    
    def delete
      !!destroy
    end
    
    def new_record?
      !!@id
    end
    
    private
    def method_missing(method_id, *args)
      cols = self.class.columns
      attr_id = method_id.to_s.gsub(/=/, '').to_sym
      
      # create dynamic accessors for attributes
      if cols.keys.include?(attr_id)
        cols.keys.each do |col_id|
          instance_eval <<-EOS
            def #{col_id}; attributes[:#{col_id}]; end
            def #{col_id}=(val); attributes[:#{col_id}]=val; end
          EOS
        end
        send(method_id, *args)
      else
        super
      end
    end
  end
end
