module Search::Modules::Ferret::FerretNodeExtension

  class Helper
    include ActionView::Helpers::SanitizeHelper
  end

  def acts_as_searchable
    require 'acts_as_ferret'

    include Search::Modules::Ferret::FerretNodeExtension::InstanceMethods
    extend  Search::Modules::Ferret::FerretMethods::ClassMethods
    include Search::Modules::Ferret::FerretMethods::InstanceMethods

    # Index any approved content, which has not been hidden or excluded from indexing.
    acts_as_ferret :fields => {
                   :content_type                    => {},
                   :content_title_to_index          => { :store => :yes, :boost => 5 },
                   :content_tokens_to_index         => { :store => :yes },
                   :publication_start_date_to_index => {},
                   :publication_end_date_to_index   => {},
                   :updated_at_to_index             => { :index => :untokenized },
                   :zipcodes_to_index               => {},
                   :ancestry_to_index               => {},
                   :is_hidden_to_index              => {},
                   :url_alias                       => { :store => :yes }
                 },
                 :if       => Proc.new { |node| node.publishable? && node.content_class.indexable? },
                 :analyzer => DevcmsCore::DutchStemmingAnalyzer.new,
                 :remote   => true,
                 :boost    => :dynamic_boost,
                 :ferret   => { :max_clauses => 2048 }
  end

  module InstanceMethods
    # Returns the path with ids for this node for indexing.
    def path_to_index
      "/#{self.self_and_ancestors.map(&:id).join("/")}/"
    end

    def ancestry_to_index
      "XX#{self.ancestry.gsub(/\//, 'X')}X"
    end

    def is_hidden_to_index
      hidden_from_index = false

      Settler[:ferret_exclude_node_ids].split(',').each do |nid|
        hidden_from_index = hidden_from_index || self.path_ids.include?(nid.to_i)
      end if Settler[:ferret_exclude_node_ids].present?

      self.hidden? || self.is_private_or_has_private_ancestor? || hidden_from_index ? 'true' : 'false'
    end

    # Returns the latest approved content title for indexing.
    def content_title_to_index
      content.content_title
    end

    def zipcodes_to_index
      if self.content_type == 'Permit'
        self.content.addresses.map { |address| address.postal_code }
      end
    end

    def updated_at_to_index
      self.updated_at.strftime(Node::INDEX_DATETIME_FORMAT)
    end

    # Returns the latest approved content tokens for indexing.
    def content_tokens_to_index
      (content.content_tokens || '').gsub(/<[^>]*>/, " ").gsub(/[[:space:]]/, ' ').gsub(/[[:space:]]{2,}/, ' ').strip
    end

    # Returns the publication date for indexing.
    def publication_start_date_to_index
      self.publication_start_date.strftime(Node::INDEX_DATETIME_FORMAT)
    end

    # Returns the publication end date for indexing
    def publication_end_date_to_index
      self.publication_end_date.nil? ? 'none' : self.publication_end_date.strftime(Node::INDEX_DATETIME_FORMAT)
    end

    # Determines the boost factor for indexing based on the node type.
    def dynamic_boost
      boost = 1.0 # default boost

      case content_class
      when Image # is less important than its parent, which may share the same name
        boost -= 0.5
      end

      # Content that has a nil body but a matching title will be ranked very high
      # because the hits/size ratio is high. Normally however nil body content
      # isn't all that interesting, so decrease its boost a bit.
      if self.content_tokens_to_index.length == 0
        boost -= 0.2
      end

      boost = boost * calculate_dynamic_boost_date_factor

      boost >= 0.1 ? boost : 0.1
    end

    # Calculates a negative boost factor based on whether the "content date" of the item is "past", "current" or "future".
    def calculate_dynamic_boost_date_factor
      # Date only matters when the content is a NewsItem, NewsletterEdition, CalendarItem or Meeting instance.
      unless [ NewsItem, NewsletterEdition, CalendarItem, Meeting ].any? { |type| content.is_a?(type) }
        boost_factor = 1
      else
        today        = Date.today
        content_date = determine_content_date(today)

        # If it's a future or past item, we apply different (negative) boost factors.
        if content_date > today
          boost_factor = (1 / (1 + Math.log((0.1  * (content_date - today).to_i) + 1)))
        elsif content_date < today
          boost_factor = (1 / (1 + Math.log((0.15 * (today - content_date).to_i) + 1)))
        # If the item is current, we do not apply a negative boost factor.
        else
          boost_factor = 1
        end
      end

      boost_factor
    end
  end
end
