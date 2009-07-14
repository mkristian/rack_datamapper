module DataMapper
  class TransactionBoundaries

    class Rollback < StandardError; end

    def initialize(app, name = :default)
      @app = app
      @name = name.to_sym
    end
  
    def call(env)
      status, headers, response = nil, nil, nil
      begin
        transaction = DataMapper::Transaction.new(DataMapper.repository(@name))
        transaction.commit do
          status, headers, response = @app.call(env)
          raise Rollback if status >= 400 or status < 200
        end
      rescue Rollback 
        # ignore, needed to trigger the rollback on the transaction
      end
      [status, headers, response]
    end
  end
end
