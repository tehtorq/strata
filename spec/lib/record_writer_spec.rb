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
  
end