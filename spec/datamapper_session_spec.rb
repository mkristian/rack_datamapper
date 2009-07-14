require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

require 'rack/mock'
require 'rack/response'
require 'thread'

[{}, { :cache => true }].each do |options|
  describe "DataMapper::Session::Datamapper with options = #{options.inspect}" do

    before :each do
      @session_key = DataMapper::Session::Datamapper::DEFAULT_OPTIONS[:key] || "rack.session"
      @session_match = /#{@session_key}=[0-9a-fA-F]+;/
        @incrementor = lambda do |env|
        env["rack.session"]["counter"] ||= 0
        env["rack.session"]["counter"] += 1
        Rack::Response.new(env["rack.session"].inspect).to_a
      end

      @drop_session = proc do |env|
        env['rack.session.options'][:drop] = true
        @incrementor.call(env)
      end

      @renew_session = proc do |env|
        env['rack.session.options'][:renew] = true
        @incrementor.call(env)
      end

      @defer_session = proc do |env|
        env['rack.session.options'][:defer] = true
        @incrementor.call(env)
      end

      @session_class = DataMapper::Session::Abstract::Session
      @session_class.auto_migrate!
    end

    it "should creates a new cookie" do
      pool = DataMapper::Session::Datamapper.new(@incrementor, options)
      res = Rack::MockRequest.new(pool).get("/")
      res["Set-Cookie"].should =~ @session_match
      res.body.should == '{"counter"=>1}'
    end
    
    it "should determines session from a cookie" do
      pool = DataMapper::Session::Datamapper.new(@incrementor, options)
      req = Rack::MockRequest.new(pool)
      cookie = req.get("/")["Set-Cookie"]
      req.get("/", "HTTP_COOKIE" => cookie).
        body.should == '{"counter"=>2}'
      req.get("/", "HTTP_COOKIE" => cookie).
        body.should == '{"counter"=>3}'
    end
    
    it "survives nonexistant cookies" do
      pool = DataMapper::Session::Datamapper.new(@incrementor, options)
      res = Rack::MockRequest.new(pool).
        get("/", "HTTP_COOKIE" => "#{@session_key}=blarghfasel")
      res.body.should == '{"counter"=>1}'
    end

    it "should delete cookies with :drop option" do
      pending if Rack.release < "1.0"
      pool = DataMapper::Session::Datamapper.new(@incrementor, options)
      req = Rack::MockRequest.new(pool)
      drop = Rack::Utils::Context.new(pool, @drop_session)
      dreq = Rack::MockRequest.new(drop)
      
      res0 = req.get("/")
      session = (cookie = res0["Set-Cookie"])[@session_match]
      res0.body.should == '{"counter"=>1}'
      @session_class.all.size.should == 1
      
      res1 = req.get("/", "HTTP_COOKIE" => cookie)
      res1["Set-Cookie"][@session_match].should == session
      res1.body.should == '{"counter"=>2}'
      @session_class.all.size.should == 1
      
      res2 = dreq.get("/", "HTTP_COOKIE" => cookie)
      res2["Set-Cookie"].should be_nil
      res2.body.should == '{"counter"=>3}'
      @session_class.all.size.should == 0

      res3 = req.get("/", "HTTP_COOKIE" => cookie)
      res3["Set-Cookie"][@session_match].should_not == session
      res3.body.should == '{"counter"=>1}'
      @session_class.all.size.should == 1
    end

    it "provides new session id with :renew option" do
      pending if Rack.release < "1.0"
      pool = DataMapper::Session::Datamapper.new(@incrementor, options)
      req = Rack::MockRequest.new(pool)
      renew = Rack::Utils::Context.new(pool, @renew_session)
      rreq = Rack::MockRequest.new(renew)

      res0 = req.get("/")
      session = (cookie = res0["Set-Cookie"])[@session_match]
      res0.body.should == '{"counter"=>1}'
      @session_class.all.size.should == 1

      res1 = req.get("/", "HTTP_COOKIE" => cookie)
      res1["Set-Cookie"][@session_match].should == session
      res1.body.should == '{"counter"=>2}'
      @session_class.all.size.should == 1

      res2 = rreq.get("/", "HTTP_COOKIE" => cookie)
      new_cookie = res2["Set-Cookie"]
      new_session = new_cookie[@session_match]
      new_session.should_not == session
      res2.body.should == '{"counter"=>3}'
      @session_class.all.size.should == 1

      res3 = req.get("/", "HTTP_COOKIE" => new_cookie)
      res3["Set-Cookie"][@session_match].should == new_session
      res3.body.should == '{"counter"=>4}'
      @session_class.all.size.should == 1
    end

    it "omits cookie with :defer option" do
      pending if Rack.release < "1.0"
      pool = DataMapper::Session::Datamapper.new(@incrementor, options)
      req = Rack::MockRequest.new(pool)
      defer = Rack::Utils::Context.new(pool, @defer_session)
      dreq = Rack::MockRequest.new(defer)

      res0 = req.get("/")
      session = (cookie = res0["Set-Cookie"])[@session_match]
      res0.body.should == '{"counter"=>1}'
      @session_class.all.size.should == 1

      res1 = req.get("/", "HTTP_COOKIE" => cookie)
      res1["Set-Cookie"][@session_match].should == session
      res1.body.should == '{"counter"=>2}'
      @session_class.all.size.should == 1

      res2 = dreq.get("/", "HTTP_COOKIE" => cookie)
      res2["Set-Cookie"].should be_nil
      res2.body.should == '{"counter"=>3}'
      @session_class.all.size.should == 1

      res3 = req.get("/", "HTTP_COOKIE" => cookie)
      res3["Set-Cookie"][@session_match].should == session
      res3.body.should == '{"counter"=>4}'
      @session_class.all.size.should == 1
    end

    # anyone know how to do this better?
    it "should merge sessions with multithreading on" do
      next unless $DEBUG
      warn 'Running multithread tests for Session::Pool'
      pool = DataMapper::Session::Datamapper.new(@incrementor, options)
      req = Rack::MockRequest.new(pool)

      res = req.get('/')
      res.body.should == '{"counter"=>1}'
      cookie = res["Set-Cookie"]
      sess_id = cookie[/#{pool.key}=([^,;]+)/,1]

      delta_incrementor = lambda do |env|
        # emulate disconjoinment of threading
        env['rack.session'] = env['rack.session'].dup
        Thread.stop
        env['rack.session'][(Time.now.usec*rand).to_i] = true
        @incrementor.call(env)
      end
      tses = Rack::Utils::Context.new pool, delta_incrementor
      treq = Rack::MockRequest.new(tses)
      tnum = rand(7).to_i+5
      r = Array.new(tnum) do
        Thread.new(treq) do |run|
          run.get('/', "HTTP_COOKIE" => cookie, 'rack.multithread' => true)
        end
      end.reverse.map{|t| t.run.join.value }
      r.each do |res|
        res['Set-Cookie'].should == cookie
        res.body.include('"counter"=>2').should be_true
      end

      session = @session_class.get(sess_id)
      session.size.should == tnum+1 # counter
      session['counter'].should == 2 # meeeh
    end
  end
end
