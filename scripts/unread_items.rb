require 'rubygems'
require 'ruger'

puts Ruger.fetch_unread_counts_for_user(ARGV[0], ARGV[1])
