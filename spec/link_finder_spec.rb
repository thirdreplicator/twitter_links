$: << File.join(File.dirname(__FILE__), '..', 'lib')
require "link_finder"

describe LinkFinder do
  def stub_http!(fixture_file_name)
    infile = File.expand_path(File.dirname(__FILE__) + "/fixtures/#{fixture_file_name}")
    @request = File.new(infile, 'r')
    TCPSocket.should_receive(:new).and_return(@request)

    # The socket is read/write. "should_receive :write" is to skip over the error that is thrown when the socket (the file) is attempted to be written while sending the request to the server.
    @request.should_receive(:write) 
  end 

  before(:each) do
    @search_term = "kardashian"
    @lf = LinkFinder.new(@search_term)
  end

  it "should should have a search term" do
    @lf.search_term.should == "kardashian"
  end

  it "should urlencode the search term" do
    jff = LinkFinder.new("just for fun")
    jff.search_term.should == "just+for+fun"
  end

  it "should be able to return the twitter search URI that it will call" do
    @lf.get_uri.should == "http://search.twitter.com/search.json?rpp=100&q=%23kardashian"
  end

  it "should be able to return the max number of tweets requested each call" do
    @lf.max_tweets.should == 100
  end

  it "should be able to call out to the get_uri" do
    stub_http!( 'http.raw.dump' )

    @lf.length.should == 0
    @lf.search!
    @lf.length.should == 1 # There is only 1 tweet in the fixture.
    @lf.tweets.should be_an_instance_of(Array)
    @lf.tweets.first[:text].should match(/Kardashian time/)
  end

  it "should have a length property that represents the number of tweets in the cache" do
    stub_http!( 'http.raw.dump' )
    @lf.length.should == 0
    @lf.search!
    @lf.length.should == 1 # There is only 1 tweet in the fixture. 
  end

  it "should be able to iterate over each tweet" do
    stub_http!( 'http.raw.dump' )
    @lf.search!
    @lf.tweets.length.should == 1
    @lf.each_tweet do |tweet|
      tweet[:text].should match(/Kardashian time/)
      tweet[:from_user].should == "rachcoop04"
    end
  end

  it "should be able to iterate over multiple tweets"  do
    stub_http!( 'http.raw.2tweets.dump' )
    @lf.search!
    @lf.tweets.length.should == 2
    @lf.each_tweet do |tweet|
      tweet[:text].should match(/(are you gonna watch #teenchoiceawards 2nite)|(VOTE!!! #KARDASHIAN! only a few days left!!!)/)
    end        
  end

  it "should have an http link regular expression" do
    "http://youtube.com/watch?v=GeD6OnJT8oE".should match( LinkFinder::REG[:link] )
  end
  
  it "should be able to return an array of links in the text content of the tweet." do
    stub_http!( 'http.raw.dump' )
    @lf.search!
    @lf.find_links!.should be_an_instance_of(Array)
    @lf.find_links!.length.should == 1
    @lf.find_links!.should include('http://tinyurl.com/3taw4dq')
  end

  it "should return a unique list of links" do
    # http://t.co/nhsFAPM was artificially inserted into both tweets.
    stub_http!( 'http.raw.2tweets.dump' )
    @lf.search!
    @lf.find_links!.should be_an_instance_of(Array)
    @lf.find_links!.length.should == 1
    @lf.find_links!.should include('http://t.co/nhsFAPM')
  end

  it "should cache the links in the .links property after #find_links was called" do
    # http://t.co/nhsFAPM was artificially inserted into both tweets.
    stub_http!( 'http.raw.2tweets.dump' )
    @lf.search!
    @lf.find_links!
    @lf.links.should be_an_instance_of(Array)
    @lf.links.length.should == 1
    @lf.links.should include('http://t.co/nhsFAPM')
  end
  
  it "should be able to find multiple links in a single tweet" do
    # Multiple links were artificially inserted into the first tweet.  There are no links in the 2nd tweet.
    stub_http!( 'http.raw.multiple_links.dump' )
    @lf.search!
    @lf.find_links!.should be_an_instance_of(Array)
    @lf.find_links!.length.should == 2
    @lf.find_links!.should include('http://t.co/nhsFAPM')    
    @lf.find_links!.should include('http://youtube.com/watch?v=GeD6OnJT8oE')    
  end
end
