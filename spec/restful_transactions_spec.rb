require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'


describe DataMapper::RestfulTransactions do

  class Name 
    include DataMapper::Resource

    property :id, Serial
    property :name, String
  end

  DataMapper.auto_migrate!

  class RestfulTransactionsApp
    def initialize(status, headers = "", response = "", &block)
      @status, @headers, @response, @block = status, headers, response, block
    end

    def call(env)
      @block.call
      [@status, @headers, @response]
    end
  end
  def mock_request(stubs={})
    @mock_request ||= mock(::Rack::Request, stubs)
  end
  
  before :each do
    ::Rack::Request.stub!(:new).with(nil).and_return(mock_request)
  end

  after :each do
    Name.all.destroy!
  end

  it 'should commit on redirects unless it is GET request' do
    mock_request.should_receive(:request_method).any_number_of_times.and_return("POST")
    app = RestfulTransactionsApp.new(301) do
      Name.create(:name => 'first')
    end
    DataMapper::RestfulTransactions.new(app).call(nil)
    Name.all.size.should == 1
    Name.first.name.should == 'first'

    app = App.new(302) do
      Name.create(:name => 'second')
    end
    DataMapper::RestfulTransactions.new(app).call(nil)
    Name.all.size.should == 2
    Name.all.last.name.should == 'second'

    app = RestfulTransactionsApp.new(303) do
      Name.create(:name => 'third')
    end
    DataMapper::RestfulTransactions.new(app).call(nil)
    Name.all.size.should == 3
    Name.all.last.name.should == 'third'

    app = RestfulTransactionsApp.new(307) do
      Name.create(:name => 'forth')
    end
    DataMapper::RestfulTransactions.new(app).call(nil)
    Name.all.size.should == 4
    Name.all.last.name.should == 'forth'
  end

  it 'should have no transaction on GET requests' do
    mock_request.should_receive(:request_method).any_number_of_times.and_return("GET")
    app = RestfulTransactionsApp.new(200) do
      Name.create(:name => 'first')
    end
    DataMapper::RestfulTransactions.new(app).call(nil)
    Name.all.size.should == 1

    app = RestfulTransactionsApp.new(500) do
      Name.create(:name => 'second')
      raise "error"
    end
    lambda { DataMapper::RestfulTransactions.new(app).call(nil) }.should raise_error
    Name.all.size.should == 2
  end

  it 'should rollback when status is not redirect and method is not GET' do
    mock_request.should_receive(:request_method).any_number_of_times.and_return("PUT")
    app = RestfulTransactionsApp.new(200) do
      Name.create(:name => 'first')
      # TODO is this read uncommited ?
      Name.all.size.should == 1
    end
    DataMapper::RestfulTransactions.new(app).call(nil)
    Name.all.size.should == 0

    app = RestfulTransactionsApp.new(404) do
      Name.create(:name => 'first')
      # TODO is this read uncommited ?
      Name.all.size.should == 1
    end
    DataMapper::RestfulTransactions.new(app).call(nil)
    Name.all.size.should == 0

    app = RestfulTransactionsApp.new(503) do
      Name.create(:name => 'first')
      # TODO is this read uncommited ?
      Name.all.size.should == 1
    end
    DataMapper::RestfulTransactions.new(app).call(nil)
    Name.all.size.should == 0
  end

end
