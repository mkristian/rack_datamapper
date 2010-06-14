# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-datamapper}
  s.version = "0.3.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["mkristian"]
  s.date = %q{2010-06-13}
  s.description = %q{this collection of plugins helps to add datamapper functionality to Rack. there is a IdentityMaps plugin which wrappes the request and with it all database actions are using that identity map. the transaction related plugin TransactionBoundaries and RestfulTransactions wrappes the request into a transaction. for using datamapper to store session data there is the DatamapperStore.}
  s.email = ["m.kristian@web.de"]
  s.extra_rdoc_files = ["History.txt", "README.txt"]
  s.files = ["History.txt", "MIT-LICENSE", "README.txt", "Rakefile"]
  s.files = s.files + 
    Dir.glob("lib/*jar") + 
    Dir.glob("lib/**/*rb")
  s.test_files = Dir.glob("spec/**/*.rb")
  s.homepage = %q{http://github.com/mkristian/rack_datamapper}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rack-datamapper}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{this collection of plugins helps to add datamapper functionality to Rack}

  s.add_runtime_dependency(%q<dm-core>, ["~> 1.0.0"])
  s.add_runtime_dependency(%q<rack>, ["~> 1.0"])

  s.add_development_dependency(%q<dm-migrations>, ["~> 1.0.0"])
  s.add_development_dependency(%q<dm-transactions>, ["~> 1.0.0"])
  s.add_development_dependency(%q<dm-sqlite-adapter>, ["~> 1.0.0"])
  s.add_development_dependency(%q<rspec>, ["~> 1.3.0"])
end

