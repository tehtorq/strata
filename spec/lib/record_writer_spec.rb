require 'spec_helper'

describe Strata::RecordWriter do
  
  it "should allow the record length to be specified" do
    
    class String
      include Strata::RecordWriter
      extend Strata::RecordWriter::ClassMethods
      
      set_record_length 200
    end
    
    string = "test1234"
    string.record_length.should == 200
  end
  
  it "should not validate characters if no character set was specified" do
    class String
      include Strata::RecordWriter
      extend Strata::RecordWriter::ClassMethods
      
      set_record_length 200
      
      string = "test1234"
      string.valid_characters("ADAWVDAWVGr#&^ @").should == true
    end
  end
  
  it "should validate that a record contains only valid characters" do
    class String
      include Strata::RecordWriter
      extend Strata::RecordWriter::ClassMethods
      
      set_record_length 200
      set_allowed_characters ('A'..'Z').to_a
      
      string = "test1234"
      string.valid_characters("ADAWVDAWVGR").should == true
      string.valid_characters("ADAWVDAWVGr").should == false
    end
  end
  
end