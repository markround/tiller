require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require "bundler/gem_tasks"

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

task :default => :features
task :test => :features
