module Strata
  module RecordWriter
  
    def layout_rules
      @layout_rules ||= self.class.class_layout_rules  
    end
  
    def exposed_rules
      layout_rules.select {|key, rule| !(rule["expose"] == false && rule.has_key?("expose")) }
    end
  
    def filler_rules
      @filler_rules ||= self.class.filler_layout_rules  
    end
  
    def set_layout_variables(options = {})
      self.class.define_attribute_accessors
    
      options.each do |k,v|
        raise "#{k}: Argument is not a string" unless v.is_a? String
        self.class.send :attr_accessor, k
        self.send "#{k}=", v.upcase
      end
    
      layout_rules.each do |k,v|
        self.class.send(:attr_accessor, k) unless (v["expose"] && v["expose"] == false)
        # self.send "#{k}=", v['fixed_val'] if v.has_key? ""
      end
    end
  
    def set_filler(string)
      filler_rules.each do |key, value|
        string[(value["offset"] - 1), value["length"]] = value["fixed_val"]
      end
    
      return string
    end
  
    def record_length
      self.class.class_variable_get(:@@record_length) || 0
    end
  
    def record_delimiter
      self.class.class_variable_get(:@@record_delimiter) || ""
    end
    
    def allowed_characters
      self.class.class_variable_get(:@@record_allowed_characters)
    end
          
    def to_s
      @string = " " * record_length + record_delimiter
      @string = set_filler(@string)
    
      @string = "#{@string}"
    
      self.exposed_rules.each do |field_name,rule|
        value = self.send(field_name) || ""

        value = value.rjust(rule['length'], "0") if rule['a_n'] == 'N'
        value = value.ljust(rule['length'], " ") if rule['a_n'] == 'A'
      
        offset = rule['offset'] - 1
        length = rule['length']
      
        @string[(offset), length] = value
      end 
    
      @string
    end
    
    def valid_characters(string)
      puts allowed_characters.inspect
      string.each_char.all? {|c| allowed_characters.include?(c)}
    end
    
    def validate_field(field_name, field_value)
      if field_name != :user_ref
        raise "#{field_name}: Invalid character used in #{field_value}" unless valid_characters(field_value)
      end
      
      raise "#{field_name}: Argument is not a string" unless field_value.is_a? String
    end
  
    def validate!(options)
      options.each do |k,v|
        rule = layout_rules[k.to_s]
        
        validate_field(k, v)
        raise "#{k}: Input too long" if v.length > rule['length']
        raise "#{k}: Invalid data" if rule['regex'] && ((v =~ /#{rule['regex']}/) != 0)
        raise "#{k}: Invalid data - expected #{rule['fixed_val']}, got #{v}" if rule['fixed_val'] && (v != rule['fixed_val'])
        raise "#{k}: Numeric value required" if (rule['a_n'] == 'N') && !(Float(v) rescue false)
      end
    end
    
    def self.matches_definition?(string)
      self.class_layout_rules.each do |field, rule|
        regex = rule['regex']
        fixed_val = rule['fixed_val']
        value = self.retrieve_field_value(string, field, rule)
        
        return false if fixed_val and value != fixed_val
        return false if regex and not value =~ /#{regex}/
      end
      
      true
    end
    
    def self.string_to_hash(string)
      hash = {}

      self.exposed_class_layout_rules.each do |field, rule|
        hash[field.to_sym] = self.retrieve_field_value(string, field, rule)
      end

      hash
    end

    def self.from_s(string)
      options = self.string_to_hash(string)
      record = self.new(options)
    end
  
    module ClassMethods
    
      def set_record_length(length)
        class_variable_set(:@@record_length, length)
      end
    
      def set_delimiter(delimiter)
        class_variable_set(:@@record_delimiter, delimiter)
      end
      
      def set_allowed_characters(chars)
        class_variable_set(:@@record_allowed_characters, chars)
      end
      
      def class_layout_rules
        file_name = "#{Absa::H2h::CONFIG_DIR}/#{self.name.split("::")[-2].underscore}.yml"
        record_type = self.name.split("::")[-1].underscore
      
        YAML.load(File.open(file_name))[record_type]
      end
    
      def exposed_class_layout_rules
        self.class_layout_rules.select {|key, rule| !(rule["expose"] == false && rule.has_key?("expose")) }
      end
    
      def filler_layout_rules
        class_layout_rules.select {|key, rule| rule.has_key?("expose") && rule["expose"] == false && rule.has_key?("fixed_val")}
      end
      
      def define_attribute_accessors
        self.class_layout_rules.each do |k,v|
          (class << self; self; end).send :attr_accessor, k
          self.send :attr_accessor, k
        end
      end
      
      def template_options
        hash = {}

        self.exposed_class_layout_rules.each do |field, rule|
          value = rule.has_key?('fixed_val') ? rule['fixed_val'] : nil

          if value
            value = value.rjust(rule['length'], "0") if rule['a_n'] == 'N'
            value = value.ljust(rule['length'], " ") if rule['a_n'] == 'A'
          end

          hash[field.to_sym] = value
        end

        hash
      end
      
      def self.retrieve_field_value(string, field, rule)
        offset = rule['offset'] - 1
        length = rule['length']
        field_type = rule['a_n']

        value = string[offset, length]

        unless rule['fixed_val']
          value = value.rstrip if field_type == 'A'
          value = value.to_i.to_s if field_type == 'N'
        end

        value
      end
    
    end
  
  end
end