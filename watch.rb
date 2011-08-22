require 'directory_watcher'

#cmd = "cucumber features"
cmd = "rspec -c spec/link_finder_spec.rb"

dw = DirectoryWatcher.new '.', :pre_load => true, :scanner => :rev
dw.glob = '**/*.{rb,feature,haml,erb}'
dw.reset true
dw.interval = 1.0
dw.stable = 1.0
system(cmd)
dw.add_observer do |*args|
  args.each do |event|
    system(cmd) if event.to_s =~ /stable/
  end
end
dw.start
gets      # when the user hits "enter" the script will terminate
dw.stop


