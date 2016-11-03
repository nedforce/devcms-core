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
  acts_as_content_node(
    available_content_representations: ['content_box']
  )

  # See the preconditions overview for an explanation of these validations.
  validates :url, presence: true
  validate :valid_feed?

  def parsed_feed
    # cache hit?
    return YAML::load(cached_parsed_feed) if cached_parsed_feed

    # cache miss
    local_parsed_feed = parse_feed

    # May be nil, in which case to_yaml would cache a NilClass, so test if
    # parse_feed returned anything meaningful.
    # Then remove all lines containing only space characters because they can
    # confuse YAML::load.
    update_attributes(cached_parsed_feed: local_parsed_feed.to_yaml.gsub(/\n\s+\n/, '\n')) if local_parsed_feed
    local_parsed_feed
  end

  # Returns the title.
  def title
    value = self.read_attribute(:title)
    return value if value.present?

    parsed_feed ? parsed_feed.title : 'Feed'
  end

  # Returns the entries of the parsed feed.
  def entries
    parsed_feed.try(:entries) || []
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
    entries.map { |entry| [entry.title, entry.description].join(' ') }.compact.join(' ')
  end

  protected

  # Read the feed.
  def read_feed
    self.xml = open(url).read.gsub(/\n/, ' ').gsub(/\s+/, ' ')
  rescue => e
    Rails.logger.error(e)
    return nil
  end

  # Parse the feed and normalize it using +FeedNormalizer+.
  def parse_feed
    read_feed if xml.blank?
    FeedNormalizer::FeedNormalizer.parse(ActiveSupport::Multibyte::Unicode.tidy_bytes(xml)) if xml.present?
  end

  # Validate that we can parse the new feed URL or restore the old XML.
  def valid_feed?
    errors.add(:url, :invalid_feed) if url.present? && !parsed_feed
  end
end
