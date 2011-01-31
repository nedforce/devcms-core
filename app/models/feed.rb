require 'feed-normalizer'
require 'open-uri'

# This model is used to represent an RSS feed.
# It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
# 
# Attributes
# 
# * +cached_parsed_feed+ - The cached parsed feed.
# * +url+ - The url of the feed.
# * +xml+ - The raw xml data of the feed.
#
# Preconditions
#
# * Requires the presence of +url+
# * Requires +url+ to yield a valid RSS document
# 
# Child/parent type constraints
# 
#  * A Feed does not accept any child nodes.
#  * A Feed can only be inserted into Section nodes.
#
class Feed < ActiveRecord::Base
  # Adds content node functionality to Feed.
  acts_as_content_node({
    :available_content_representations => ['content_box']
  })

  # See the preconditions overview for an explanation of these validations.
  validates_presence_of :url
  validate :valid_feed?
  
  def parsed_feed
    # cache hit?
    return YAML::load(cached_parsed_feed) if cached_parsed_feed

    # cache miss
    local_parsed_feed = parse_feed

    # May be nil, in which case to_yaml would cache a NilClass, so test if parse_feed returned anything meaningful.
    # Then remove all lines containing only space characters because they can confuse YAML::load.
    update_attribute(:cached_parsed_feed, local_parsed_feed.to_yaml.gsub(/\n\s+\n/, '\n')) if local_parsed_feed
    local_parsed_feed
  end

  # Returns the title.
  def title
    title = super
    title.blank? ? (parsed_feed ? parsed_feed.title : 'Feed') : title
  end

  # Returns the entries of the parsed feed.
  def entries
    parsed_feed.entries
  end
  
  # Update the feed
  def update_feed
    self.xml = nil
    save # will call read_feed
  end
  
  # Set a new URL and clear the XML cache
  def url=(new_url)
    super(new_url)
    self.xml = nil
  end
  
  # Sets the new XML and clears the parsed feed cache
  def xml=(new_xml)
    super(new_xml)
    self.cached_parsed_feed = nil
  end

  # Returns the entry titles and descriptions as the tokens for indexing.
  def content_tokens
    entries.map { |entry| [ entry.title, entry.description ].compact.join(' ') }.compact.join(' ')
  end

  protected

  # Read the feed.
  def read_feed
    begin
      self.xml = open(url).read.gsub(/\n/, ' ').gsub(/\s+/, ' ')
    rescue Exception => e
      nil
    ensure
      # open-uri may leave Tempfiles lingering if the garbage collector is
      # not triggered before the application loop exits.
      GC.start
    end
  end

  # Parse the feed and normalize it using +FeedNormalizer+.
  def parse_feed
    read_feed if xml.blank?
    begin
      FeedNormalizer::FeedNormalizer.parse(xml)
    ensure
      # Force-start the garbage collector to clean up after FeedNormalizer leaks.
      GC.start
    end
  end

  # Validate that we can parse the new feed URL or restore the old XML.
  def valid_feed?
    errors.add(:url, :invalid_feed) unless self.url.blank? || parsed_feed
  end
end

# == Schema Information
#
# Table name: feeds
#
#  id                 :integer         not null, primary key
#  url                :string(255)     not null
#  created_at         :datetime
#  updated_at         :datetime
#  title              :string(255)
#  cached_parsed_feed :text
#  xml                :binary
#