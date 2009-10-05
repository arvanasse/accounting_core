module InactiveRecord
  class SchemaError < InactiveRecordError; end
  module Schema
    class Column
      attr_reader :name, :data_type, :default
      def initialize(name, data_type, default=nil)
        @name = name
        @data_type = simplified_type(data_type)
        raise(InactiveRecord::SchemaError, "Default value does not match required data type") unless correct_data_type?(default)
        @default = default
      end
      
      def klass
        case data_type
          when :integer       then Fixnum
          when :float         then Float
          when :decimal       then BigDecimal
          when :datetime      then Time
          when :date          then Date
          when :timestamp     then Time
          when :time          then Time
          when :text, :string then String
          when :binary        then String
          when :boolean       then Object
        end
      end
      
      def correct_data_type?(val)
        val.nil? || val.is_a?(klass)
      end
      
      private
      def simplified_type(field_type)
        case field_type.to_s
          when /int/i
            :integer
          when /float|double/i
            :float
          when /decimal|numeric|number/i
            extract_scale(field_type) == 0 ? :integer : :decimal
          when /datetime/i
            :datetime
          when /timestamp/i
            :timestamp
          when /time/i
            :time
          when /date/i
            :date
          when /clob/i, /text/i
            :text
          when /blob/i, /binary/i
            :binary
          when /char/i, /string/i
            :string
          when /boolean/i
            :boolean
        end
      end
    end
    
    class TableDefinition
      def initialize(target)
        @base = target
      end
      
      def column(name, data_type, options)
        options ||= {}
        @base.add_column Column.new(name, data_type, options[:default])
      end
      
      %w{string text integer float decimal datetime time date binary boolean}.each do |column_type|
        class_eval <<-EOS
          def #{column_type}(*args)
            options = args.last.is_a?(Hash) ? args.pop : {}
            column_names = args

            column_names.each do |name|
              column(name, :#{column_type}, options)
            end
          end
        EOS
      end
    end
  end
end