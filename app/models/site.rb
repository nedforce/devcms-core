# A Site is a content node that represents the whole site or a subsite of the site, as identified by a domain. All the content
# of a (sub-)site is scoped within a Site node. It has specified +acts_as_content_node+ from Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +domain+ - The domain of the site, can be left blank if it's the 'top' site.
#
# Preconditions
#
# * Requires the format of +domain+ to conform to VALID_DOMAIN_REGEXP, if specified.
class Site < Section
  
  acts_as_content_node({
    :allowed_child_content_types => %w(
      AlphabeticIndex Attachment Calendar Carrousel CombinedCalendar ContactBox ContactForm Feed Forum
      HtmlPage Image LegislationArchive InternalLink ExternalLink NewsArchive NewsletterArchive NewsViewer
      Page PermitArchive PermitViewer Poll ProductCatalogue SearchPage Section Site SocialMediaLinksBox TopHitsPage WeblogArchive
    ),
    :allowed_roles_for_create  => %w( admin ),
    :allowed_roles_for_update  => %w( admin ),
    :allowed_roles_for_destroy => %w( admin ),
    :available_content_representations => ['content_box'],
    :has_own_content_box => true,
    :controller_name => 'sites',
    :show_in_menu => false,
    :copyable => false
  })
  
  VALID_DOMAIN_REGEXP = /\A(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)\Z/i

  validates_presence_of   :domain,                       :unless => Proc.new { |s| s.parent.blank? }
  validates_format_of     :domain, :allow_blank => true, :with => VALID_DOMAIN_REGEXP
  validates_uniqueness_of :domain, :allow_blank => true

  validate :ensure_parent_is_root

  def self.find_by_domain(domain)
    site = Site.first(:include => :node, :conditions => [ 'sections.domain = ? OR sections.domain = ?', domain, 'www.' + domain ])
    site ||= Node.root.content #if domain == 'localhost'
    return site
  end

  protected

  def ensure_parent_is_root
    self.errors.add_to_base(:parent_must_be_root_or_not_a_site) if self.parent && !self.parent.root?
  end
end
