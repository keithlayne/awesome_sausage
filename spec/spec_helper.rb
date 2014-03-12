require 'rubygems'
require 'spork'

def load_simplecov
  begin
    require 'simplecov'
    SimpleCov.start do
      add_filter '/spec/'
    end
  rescue LoadError
    STDERR.puts 'SimpleCov not installed.  Not generating coverage report.'
  end
end

Spork.prefork do
  # load_simplecov unless ENV['DRB']

  require 'rspec'
  RSpec.configure do |config|
    config.treat_symbols_as_metadata_keys_with_true_values = true
    config.run_all_when_everything_filtered = true
    config.filter_run :focus
    config.order = 'random'
  end
end

Spork.each_run do
  # load_simplecov if ENV['DRB']
  RSpec.configuration.seed = rand(100000)
  require 'awesome_sausage'
end


