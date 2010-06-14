#!/bin/ruby
require 'rubygems'

raise "needs rubygems version >=1.3.6" if Gem::VERSION < "1.3.6"
load '../jruby-maven-plugins/gem-proxy/src/main/resources/gem_artifacts.rb'
m = Maven::LocalRepository.new
File.open("pom.xml", "w") do |f|
  f << m.to_pomxml('rack_datamapper.gemspec')
end
