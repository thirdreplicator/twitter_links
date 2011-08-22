require 'yajl/http_stream'
require 'cgi'
require 'uri'

class LinkFinder
  attr_reader :search_term, :max_tweets, :tweets, :links
  REG = {}
  REG[:link] = /((https?:\/\/|www\.)([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/
  
  def initialize( search_term )
    @search_term = CGI::escape( search_term )
    @max_tweets = 100
    @tweets = []
    @links = []
  end

  def get_uri
    "http://search.twitter.com/search.json?rpp=#{@max_tweets}&q=%23#{@search_term}"
  end

  def search!
    uri = URI.parse( get_uri )
    Yajl::HttpStream.get(uri, :symbolize_keys => true) do |hash|
      hash[:results].each do |tweet|
          tweets << tweet
      end
    end
    self
  end 
  
  def length
    @tweets.length
  end

  # Iterate over each tweet.
  def each_tweet(&block)
    @tweets.each do |tweet|
      block.call(tweet)
    end
  end

  # Iterate over the textual content of the tweet only.
  def find_links!
    each_tweet do |tweet|
      text = tweet[:text].dup
      while matched = text.match(REG[:link])
        @links << matched.to_s if matched
        text.sub!(REG[:link], '')
      end
    end
    @links.uniq!
    @links
  end
end
