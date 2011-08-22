Given /^I am at the command line$/ do
  # Don't need to do anything to be at the command line....
end

When /^I type "([^"]*)" at the command line$/ do |cmd|
  @output = `#{cmd}`
end

Then /^I should see a unique list of urls$/ do
  num_lines = 0
  urls = []
  @output.each_line do |line|
    num_lines += 1
    line.chomp!
    # each line should be a url.
    line.should match(/http:\/\//)
    urls << line
  end

  # The list of urls should be unique already.
  num_lines.should == urls.uniq.length
end

