require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause
# this file to always be loaded, without a need to explicitly require it in any
# files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need
# it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require File.expand_path('../../config/environment', __FILE__)
require 'rails/all'
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'rspec/example_steps'
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

# I had to include this, /d.wessman 2015-03-20
require 'database_cleaner'
# Devise helpers
require 'devise'

Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
RSpec.configure do |config|
  config.include Devise::TestHelpers, type: 'controller'
  config.extend ControllerMacros, type: 'controller'
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = [:should]
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  #config.filter_run :focus
  #config.run_all_when_everything_filtered = true

  #config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.order = :random

  Kernel.srand config.seed
end

def build(*args)
  FactoryGirl.build(*args)
end

def create(*args)
  FactoryGirl.create(*args)
end


