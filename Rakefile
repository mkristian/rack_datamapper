# -*- ruby -*-

require 'rubygems'

require 'spec'
require 'spec/rake/spectask'
require 'pathname'
require 'yard'

desc "Run specs"
Spec::Rake::SpecTask.new('spec')

task :clean do
  sh "rm -r pkg"
end

desc 'Package as a gem.'
task :package do
  sh "gem build rack_datamapper.gemspec" 
  sh "mkdir -p pkg"
  sh "mv rack-datamapper-*.gem pkg"
end

desc 'Install the package as a gem.'
task :install => [:clean, :package] do
  gem = Dir['pkg/*.gem'].first
  sh "gem install --local #{gem} --no-ri --no-rdoc"
end

YARD::Rake::YardocTask.new

# vim: syntax=Ruby
