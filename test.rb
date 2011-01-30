require './lib/uspstracking'

a = Uspstracking::Tracking.new(ARGV[0])
a.getTracking
p a

