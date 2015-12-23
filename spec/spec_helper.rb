$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
require 'attention'
require 'pry'
require 'rspec/its'
require 'timecop'
Dir['./spec/support/**/*.rb'].sort.each{ |f| require f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.disable_monkey_patching!
  Kernel.srand config.seed

  config.before(:each){ Timecop.freeze }
  config.after(:each){ Timecop.return }
end
