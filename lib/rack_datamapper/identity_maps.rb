module DataMapper
  class IdentityMaps
    def initialize(app, name = :default)
      @app = app
      @name = name.to_sym
    end
  
    def call(env)
      status, headers, response = nil, nil, nil
      DataMapper.repository(@name) do
        status, headers, response = @app.call(env)
      end
      [status, headers, response]
    end
  end
end
