begin
  require 'rubygems'
  require 'ruger'

  puts Ruger.fetch_unread_counts_for_user(ARGV[0], ARGV[1])
rescue LoadError
  puts "666" # That should get my attention if the gem goes missing
end
