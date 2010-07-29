# -*- ruby -*-

require 'rubygems'
require './lib/rack_datamapper/version.rb'

require 'spec'
require 'spec/rake/spectask'

build_dir = 'target'

desc 'clean up'
task :clean do
  FileUtils.rm_rf(build_dir)
end

desc 'package as a gem.'
task :package do
  require 'fileutils'
  gemspec = Dir['*.gemspec'].first
  sh "gem build #{gemspec}"
  FileUtils.mkdir_p(build_dir)
  gem = Dir['*.gem'].first
  FileUtils.mv(gem, File.join(build_dir,"#{gem}"))
end

desc 'Install the package as a gem.'
task :install => [:package] do
  gem = Dir[File.join(build_dir, '*.gem')].first
  sh "gem install --local #{gem} --no-ri --no-rdoc"
end

desc 'Run specifications'
Spec::Rake::SpecTask.new(:spec) do |t|
  if File.exists?(File.join('spec','spec.opts'))
    t.spec_opts << '--options' << File.join('spec','spec.opts')
  end
  t.spec_files = Dir.glob(File.join('spec','**','*_spec.rb'))
end

# vim: syntax=Ruby
