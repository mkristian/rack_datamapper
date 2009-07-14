require 'rack/session/abstract/id'
require 'rack_datamapper/session/abstract/store'

module DataMapper
  module Session
    class Datamapper < ::Rack::Session::Abstract::ID
      
      def initialize(app, options = {})
        super
        id_generator = Proc.new do 
          generate_sid
        end
        @store = ::DataMapper::Session::Abstract::Store.new(app, options, id_generator)
      end
      
      private

      def get_session(env, sid)
        @store.get_session(env, sid)
      end
      
      def set_session(env, sid, session_data, options)
        @store.set_session(env, sid, session_data, options)
      end
    end
  end
end
