
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "hrr_rb_ssh/version"

Gem::Specification.new do |spec|
  spec.name          = "hrr_rb_ssh"
  spec.version       = HrrRbSsh::VERSION
  spec.authors       = ["hirura"]
  spec.email         = ["hirura@gmail.com"]

  spec.summary       = %q{SSH2 protocol implementation}
  spec.description   = %q{SSH2 protocol implementation}
  spec.homepage      = "https://github.com/hirura/hrr_rb_ssh"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "http://mygemserver.com"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 1.0.8"
end
