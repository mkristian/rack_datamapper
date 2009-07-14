require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

describe DataMapper::IdentityMaps do

  class Name 
    include DataMapper::Resource

    property :id, Serial
    property :name, String
  end

  DataMapper.auto_migrate!

  class App
    def initialize(status = 200, headers = "", response = "", &block)
      @status, @headers, @response, @block = status, headers, response, block
    end

    def call(env)
      @block.call
      [@status, @headers, @response]
    end
  end

  after :each do
    Name.all.destroy!
  end

  it 'should collect resources loaded from the datasource' do
    app = App.new do
      Name.create(:name => 'first')
      repository.identity_map(Name).size.should == 1
      Name.create(:name => 'second')
      repository.identity_map(Name).size.should == 2
      Name.create(:name => 'third')
      repository.identity_map(Name).size.should == 3
    end
    DataMapper::IdentityMaps.new(app).call(nil)
    
    Name.all.size.should == 3
      
    repository.identity_map(Name).size.should == 0
  end

end
