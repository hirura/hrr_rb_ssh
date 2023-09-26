require "bundler/setup"

if ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    #add_filter '/spec/'
  end
end

# Enable legacy providers such as blowfish-cbc, cast128-cbc, arcfour
ENV['OPENSSL_CONF'] = File.expand_path(
  File.join(File.dirname(__FILE__), 'support', 'openssl.conf')
)
require "hrr_rb_ssh"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
