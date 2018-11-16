# Copyright (c) 2011-2016 Solano Labs All Rights Reserved

require "./lib/solano/version"

Gem::Specification.new do |s|
  s.name        = "solano"
  s.version     = Solano::VERSION
  s.platform    = (RUBY_PLATFORM == 'java' ? RUBY_PLATFORM : Gem::Platform::RUBY)
  s.authors     = ["GE Digital LLC"]
  s.email       = ["build-ge-solano@ge.com"]
  s.homepage    = "https://github.com/solanolabs/solano.git"
  s.summary     = "Run tests in Predix CI Hosted Test Environment"
  s.license     = "MIT"
  s.description = <<-EOF
Predix CI runs your test suite simply and quickly in our managed
cloud environment.  You can run tests by hand, or enable our hosted CI to watch
your git repos automatically.

Predix CI automatically and safely parallelizes your tests to save you time, and
takes care of setting up fresh isolated DB instances for each test thread.

Tests have access to a wide variety of databases (postgres, mongo, redis,
mysql, memcache), solr, sphinx, selenium/webdriver browsers, webkit and culerity.

Predix CI supports all common Ruby test frameworks, including rspec, cucumber,
test::unit, and spinach.  Predix CI also supports Javascript testing using
jasmine, evergreen, and many other frameworks.
EOF

  s.files         = `git ls-files lib bin`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }

  s.add_runtime_dependency("thor")
  s.add_runtime_dependency("highline", "~> 1.7.3")
  s.add_runtime_dependency("json", "~> 1.8.3")
  s.add_runtime_dependency("launchy", "~> 2.4")
  s.add_runtime_dependency("addressable", "~> 2.3")
  s.add_runtime_dependency("tddium_client", "~> 0.6", ">= 0.6.5")
  s.add_runtime_dependency("nayutaya-msgpack-pure", "~> 0.0", ">= 0.0.2")
  s.add_runtime_dependency("public_suffix", "~> 1.4.6 ")

  s.add_development_dependency("aruba", "0.4.6")
  s.add_development_dependency("rdiscount", "1.6.8")
  s.add_development_dependency("pickle", "~> 0.5")
  s.add_development_dependency("mimic", "~> 0.4")
  s.add_development_dependency("daemons", "~> 1.1")
  s.add_development_dependency("httparty", "~> 0.10.0")
  s.add_development_dependency("httpclient", "2.4.0")
  s.add_development_dependency("antilles", "~> 0.1")
  s.add_development_dependency("rspec", "~> 3.1")
  s.add_development_dependency("cucumber","~> 1.3")
  s.add_development_dependency("fakefs", "~> 0.6")
  s.add_development_dependency("simplecov", "~> 0.9")
  s.add_development_dependency("rake", "~> 10.4")
end
