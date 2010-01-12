require 'rack'
module DataMapper
  class RestfulTransactions

    class Rollback < StandardError; end

    def initialize(app, name = :default)
      @app = app
      @name = name.to_sym
    end
  
    def call(env)
      request = ::Rack::Request.new(env)
      if ["POST", "PUT", "DELETE"].include? request.request_method
        status, headers, response = nil, nil, nil
        begin
          transaction = DataMapper::Transaction.new(DataMapper.repository(@name))
          transaction.commit do
            status, headers, response = @app.call(env)
            raise Rollback unless (200 <= status && status < 400)
          end
        rescue Rollback 
          # ignore, 
          # this is just needed to trigger the rollback on the transaction
        end
        [status, headers, response]
      else
        @app.call(env)        
      end
    end
  end
end
