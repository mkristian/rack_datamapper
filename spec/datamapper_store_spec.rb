$LOAD_PATH << File.dirname(__FILE__)
require 'spec_helper'

describe DataMapper::Session::Abstract::Store do

  describe 'without cache' do

    def mock_session(stubs={})
      @mock_session ||= mock(DataMapper::Session::Abstract::Session, stubs)
    end

    before :each do
      @store = DataMapper::Session::Abstract::Store.new(nil, 
                                                       {}, 
                                                       Proc.new do
                                                          1
                                                       end
                                                       )
    end

    it 'should get the session data' do
      DataMapper::Session::Abstract::Session.stub!(:get).and_return(mock_session)
      mock_session.should_receive(:data).and_return({:id => "id"})
      @store.get_session({}, "sid").should == ["sid",{:id => "id"}]
    end

    it 'should create a new session' do
      DataMapper::Session::Abstract::Session.should_receive(:create).and_return(mock_session)
      mock_session.should_receive(:data).and_return({})
      result = @store.get_session({}, nil)
      result[0].should_not be_nil
      result[1].should == {}
    end

    it 'should set the session data' do
      DataMapper::Session::Abstract::Session.should_receive(:create).and_return(mock_session)
      DataMapper::Session::Abstract::Session.should_receive(:get).twice.and_return(mock_session)
      mock_session.should_receive(:data).and_return({})
      mock_session.should_receive(:data=).with({:id => 432})
      mock_session.should_receive(:save).and_return(true)
      mock_session.should_receive(:data).and_return({:id => 123})
      
      session_id = @store.get_session({}, nil)[0]
      mock_session.should_receive(:session_id).and_return(session_id);
      @store.set_session({}, session_id, {:id => 432}, {}).should == session_id
      result =  @store.get_session({}, session_id)
      
      result[0].should_not be_nil
      result[1].should == {:id => 123}
    end

    it 'should delete empty sessions' do
      DataMapper::Session::Abstract::Session.should_receive(:create).and_return(mock_session)
      DataMapper::Session::Abstract::Session.should_receive(:get).and_return(mock_session)
      mock_session.should_receive(:data).and_return({})
      mock_session.should_receive(:data=).with({})
      mock_session.should_receive(:destroy).and_return(true)

      session_id = @store.get_session({}, nil)[0]
      @store.set_session({}, session_id, {}, {}).should be_false
    end
  end

  describe 'with cache' do
    
    def mock_session(stubs={})
      @mock_session ||= mock(DataMapper::Session::Abstract::Session, stubs)
    end

    before :each do
      @store = DataMapper::Session::Abstract::Store.new(nil, 
                                                        {:cache => true}, 
                                                        Proc.new do
                                                          1
                                                        end)
    end

    it 'should create a new session' do
      DataMapper::Session::Abstract::Session.should_receive(:create).and_return(mock_session)
      mock_session.should_receive(:data).and_return({})
      result = @store.get_session({}, nil)
      result[0].should_not be_nil
      result[1].should == {}
    end

    it 'should get the session data from storage' do
      DataMapper::Session::Abstract::Session.stub!(:get).and_return(mock_session)
      mock_session.should_receive(:data).twice.and_return({:id => "id"})
      @store.get_session({}, "sid").should == ["sid",{:id => "id"}]
      # second get should use the cache
      @store.get_session({}, "sid").should == ["sid",{:id => "id"}]
    end

    it 'should get the session data from cache' do
      DataMapper::Session::Abstract::Session.should_receive(:create).and_return(mock_session)
      mock_session.should_receive(:data).twice.and_return({})
      session_id = @store.get_session({}, nil)[0]
      
      result =  @store.get_session({}, session_id)
      result[0].should_not be_nil
      result[1].should == {}
    end

    it 'should set the session data with empty cache' do
      DataMapper::Session::Abstract::Session.should_receive(:get).and_return(mock_session)
      mock_session.should_receive(:data=).with({:id => 432})
      mock_session.should_receive(:save).and_return(true)
      mock_session.should_receive(:session_id).and_return("sid")
      mock_session.should_receive(:data).and_return({:id => 123})
      @store.set_session({}, "sid", {:id => 432},{}).should == "sid"
      result =  @store.get_session({}, "sid")

      result[0].should_not be_nil
      result[1].should == {:id => 123}
    end

    it 'should set the session data' do
      DataMapper::Session::Abstract::Session.should_receive(:create).and_return(mock_session)
      mock_session.should_receive(:data).and_return({})
      mock_session.should_receive(:data=).with({:id => 432})
      mock_session.should_receive(:save).and_return(true)
      mock_session.should_receive(:data).and_return({:id => 123})

      session_id = @store.get_session({}, nil)[0]
      mock_session.should_receive(:session_id).and_return(session_id);
      @store.set_session({}, session_id, {:id => 432},{}).should == session_id
      result =  @store.get_session({}, session_id)

      result[0].should_not be_nil
      result[1].should == {:id => 123}
    end

    it 'should delete empty sessions' do
      DataMapper::Session::Abstract::Session.should_receive(:create).and_return(mock_session)
      mock_session.should_receive(:data).and_return({})
      mock_session.should_receive(:data=).with({})
      mock_session.should_receive(:destroy).and_return(true)

      session_id = @store.get_session({}, nil)[0]
      @store.set_session({}, session_id, {}, {}).should be_false
    end
  end
end
