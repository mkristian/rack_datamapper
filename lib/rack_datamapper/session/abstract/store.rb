require 'dm-core'
require 'base64'
module DataMapper
  module Session
    module Abstract
      class Store

        def initialize(app, options, id_generator)
          @mutex = Mutex.new
          if cache = options.delete(:cache)
            @@cache = if RUBY_PLATFORM =~ /java/
                        begin
                          # to avoid memory leaks use a hashmap which clears
                          # itself on severe memory shortage
                          require 'softhashmap'
                          m = Java.SoftHashMap.new
                          def m.delete(key)
                            remove(key)
                          end
                          m
                        rescue
                          # fallback to non java Hash
                          {}
                        end
                      else
                        {}
                      end
            @@semaphore = Mutex.new
          else
            @@cache = nil unless cache.nil? && self.class.class_variable_defined?(:@@cache)
          end
          @@session_class = options.delete(:session_class) || Session unless (self.class.class_variable_defined?(:@@session_class) and @@session_class)
          @id_generator = id_generator
        end
        
        def get_session(env, sid)
          @mutex.lock if env['rack.multithread']
          if sid
            session = 
              if @@cache
                @@cache[sid] || @@cache[sid] = @@session_class.get(sid)
              else
                @@session_class.get(sid)
              end
          end

          unless sid and session
            env['rack.errors'].puts("Session '#{sid.inspect}' not found, initializing...") if $VERBOSE and not sid.nil?
            sid = @id_generator.call
            session = @@session_class.create(:session_id => sid)
            @@cache[sid] = session if @@cache
          end
          #session.instance_variable_set('@old', {}.merge(session))

          return [sid, session.data]
        ensure
          @mutex.unlock if env['rack.multithread']
        end
        
        def set_session(env, sid, session_data, options)
          @mutex.lock if env['rack.multithread']
          session = 
            if @@cache
              @@cache[sid] || @@cache[sid] = @@session_class.get(sid)
            else
              @@session_class.get(sid)
            end 
          return false if session.nil?
          if options[:renew] or options[:drop]
            @@cache.delete(sid) if @@cache
            session.destroy
            return false if options[:drop]
            sid = @id_generator.call
            session = @@session_class.create(:session_id => sid)
            @@cache[sid] = session if @@cache
          end
          #        old_session = new_session.instance_variable_get('@old') || {}
          #        session = merge_sessions session_id, old_session, new_session, session
          session.data = session_data
          if session_data.empty?
            @@cache.delete(sid) if @@cache
            session.destroy
            false
          elsif session.save
            session.session_id
          else
            warn session.errors.inspect if session.errors.size > 0
            false
          end
        ensure
          @mutex.unlock if env['rack.multithread']
        end
      end
      
      class Session
        
        include ::DataMapper::Resource
        
        def self.default_storage_name
          "Session"
        end
        
        property :session_id, String, :key => true
        
        property :raw_data, Text, :required => true, :default => ::Base64.encode64(Marshal.dump({})), :field => 'data'
        
        property :updated_at, DateTime, :required => false, :index => true
        
        def data=(data)
           attribute_set(:raw_data, ::Base64.encode64(Marshal.dump(data)))
        end
        
        def data
          Marshal.load(::Base64.decode64(attribute_get(:raw_data)))
        end
      end
    end
  end
end
