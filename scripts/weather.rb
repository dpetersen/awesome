require 'rubygems'
require 'yahoo-weather'

zip = ARGV[0]
raise "You need to give me a ZIP code!" if zip.nil?

client = YahooWeather::Client.new
response = client.lookup_location(zip)

print "#{response.condition.temp}° #{response.condition.text}"
