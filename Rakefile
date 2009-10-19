# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/rack_datamapper/version.rb'

require 'spec'
require 'spec/rake/spectask'
require 'pathname'
require 'yard'

Hoe.spec('rack-datamapper') do |p|
  p.developer('mkristian', 'm.kristian@web.de')
  p.extra_deps = [['dm-core', '>0.9.10']]
  p.rspec_options << '--options' << 'spec/spec.opts'
end

desc 'Install the package as a gem.'
task :install => [:clean, :package] do
  gem = Dir['pkg/*.gem'].first
  sh "gem install --local #{gem} --no-ri --no-rdoc"
end

YARD::Rake::YardocTask.new

# vim: syntax=Ruby
