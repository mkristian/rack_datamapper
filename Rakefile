# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/rack_datamapper/version.rb'

require 'spec'
require 'spec/rake/spectask'
require 'pathname'
require 'yard'

Hoe.new('rack_datamapper', Rack::DataMapper::VERSION) do |p|
  # p.rubyforge_name = 'dm-utf8x' # if different than lowercase project name
  p.developer('mkristian', 'm.kristian@web.de')
end

desc 'Install the package as a gem.'
task :install => [:clean, :package] do
  gem = Dir['pkg/*.gem'].first
  sh "gem install --local #{gem} --no-ri --no-rdoc"
end

desc 'Run specifications'
Spec::Rake::SpecTask.new(:spec) do |t|
  if File.exists?('spec/spec.opts')
    t.spec_opts << '--options' << 'spec/spec.opts'
  end
  t.spec_files = Pathname.glob('./spec/**/*_spec.rb')
end

require 'yard'

YARD::Rake::YardocTask.new

# vim: syntax=Ruby
