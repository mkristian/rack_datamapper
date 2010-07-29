# create by maven - leave it as is
Gem::Specification.new do |s|
  s.name = 'rack-datamapper'
  s.version = '0.3.3'

  s.summary = 'this collection of plugins helps to add datamapper functionality to Rack'
  s.description = 'this collection of plugins helps to add datamapper functionality to Rack. there is a IdentityMaps plugin which wrappes the request and with it all database actions are using that identity map. the transaction related plugin TransactionBoundaries and RestfulTransactions wrappes the request into a transaction. for using datamapper to store session data there is the DatamapperStore.'
  s.homepage = 'http://github.com/mkristian/rack_datamapper'

  s.authors = ['mkristian']
  s.email = ['m.kristian@web.de']

  s.files = Dir['MIT-LICENSE']
  s.licenses << 'MIT-LICENSE'
  s.files += Dir['lib/**/*']
  s.files += Dir['spec/**/*']
  s.test_files += Dir['spec/**/*_spec.rb']
  s.add_dependency 'dm-core', '~> 1.0.0'
  s.add_dependency 'rack', '~> 1.0'
  s.add_development_dependency 'dm-migrations', '~> 1.0.0'
  s.add_development_dependency 'dm-transactions', '~> 1.0.0'
  s.add_development_dependency 'dm-sqlite-adapter', '~> 1.0.0'
  s.add_development_dependency 'rspec', '~> 1.3.0'
end