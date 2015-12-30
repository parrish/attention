require 'bundler/setup'
require 'attention'

# Listen to changes from other servers
Attention.on_change do |change, instances|
  p change, instances
end

Attention.activate port: ARGV[0]

sleep
