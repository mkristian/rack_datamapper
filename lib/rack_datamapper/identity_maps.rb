module DataMapper
  class IdentityMaps
    def initialize(app, name = :default)
      @app = app
      @name = name.to_sym
    end
  
    def call(env)
      DataMapper.repository(@name) do
        @app.call(env)
      end
    end
  end
end
