$: << "lib"
require 'link_finder'

lf = LinkFinder.new(ARGV[0])
lf.search!
lf.find_links!.each do |link|
  puts "#{link}"
end