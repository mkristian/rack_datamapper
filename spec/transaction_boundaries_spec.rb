require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

describe DataMapper::TransactionBoundaries do

  class Name 
    include DataMapper::Resource

    property :id, Serial
    property :name, String
  end

  DataMapper.auto_migrate!

  class TransactionBoundariesApp
    def initialize(status, headers = "", response = "", &block)
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

  it 'should commit on status < 400 and status >= 200' do
    app = TransactionBoundariesApp.new(301) do
      Name.create(:name => 'first')
    end
    DataMapper::TransactionBoundaries.new(app).call(nil)
    Name.all.size.should == 1
    Name.first.name.should == 'first'

    app = TransactionBoundariesApp.new(200) do
      Name.create(:name => 'second')
    end
    DataMapper::TransactionBoundaries.new(app).call(nil)
    Name.all.size.should == 2
    Name.all.last.name.should == 'second'

    app = TransactionBoundariesApp.new(303) do
      Name.create(:name => 'third')
    end
    DataMapper::TransactionBoundaries.new(app).call(nil)
    Name.all.size.should == 3
    Name.all.last.name.should == 'third'

    app = TransactionBoundariesApp.new(222) do
      Name.create(:name => 'forth')
    end
    DataMapper::TransactionBoundaries.new(app).call(nil)
    Name.all.size.should == 4
    Name.all.last.name.should == 'forth'
  end

  it 'should rollback on status < 200 or status >= 400' do
    app = TransactionBoundariesApp.new(100) do
      Name.create(:name => 'first')
      # TODO is this read uncommited ?
      Name.all.size.should == 1
    end
    DataMapper::TransactionBoundaries.new(app).call(nil)
    Name.all.size.should == 0

    app = TransactionBoundariesApp.new(404) do
      Name.create(:name => 'first')
      # TODO is this read uncommited ?
      Name.all.size.should == 1
    end
    DataMapper::TransactionBoundaries.new(app).call(nil)
    Name.all.size.should == 0

    app = TransactionBoundariesApp.new(500) do
      Name.create(:name => 'first')
      # TODO is this read uncommited ?
      Name.all.size.should == 1
    end
    DataMapper::TransactionBoundaries.new(app).call(nil)
    Name.all.size.should == 0
  end

end
