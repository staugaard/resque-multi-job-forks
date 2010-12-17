# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "resque-multi-job-forks"
  s.version     = "0.2.0"
  s.authors     = ["Mick Staugaard"]
  s.email       = ["mick@zendesk.com"]
  s.homepage    = "http://github.com/staugaard/resque-multi-job-forks"
  s.summary     = "Have your resque workers process more that one job"
  s.description = "When your resque jobs are frequent and fast, the overhead of forking and running your after_fork might get too big."

  s.add_runtime_dependency("resque", "< 1.8.0")
  s.add_runtime_dependency("redis", "< 2.0")
  s.add_runtime_dependency("json")

  s.add_development_dependency("rake")
  s.add_development_dependency("bundler")

  s.files         = Dir["lib/**/*"]
  s.test_files    = Dir["test/**/*"]
  s.require_paths = ["lib"]
end
