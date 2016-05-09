# A Site is a content node that represents the whole site or a subsite of the
# site, as identified by a domain. All the content of a (sub-)site is scoped
# within a Site node. It has specified +acts_as_content_node+ from
# Acts::ContentNode::ClassMethods.
#
# *Specification*
#
# Attributes
#
# * +domain+ - The domain of the site, can be left blank if it's the 'top' site.
#
# Preconditions
#
# * Requires the format of +domain+ to conform to VALID_DOMAIN_REGEXP, if
#   specified.
class Site < Section
  acts_as_content_node(
    allowed_child_content_types: %w(
      AlphabeticIndex Attachment AttachmentTheme Calendar Carrousel
      CombinedCalendar ContactBox ContactForm FaqArchive Feed Forum HtmlPage
      Image LinksBox InternalLink ExternalLink NewsArchive NewsletterArchive
      NewsViewer Page Poll SearchPage Section Site SocialMediaLinksBox
      TopHitsPage WeblogArchive
    ),
    allowed_roles_for_create:          %w( admin ),
    allowed_roles_for_update:          %w( admin ),
    allowed_roles_for_destroy:         %w( admin ),
    available_content_representations: %w( content_box ),
    has_own_content_box:               true,
    controller_name:                   'sites',
    show_in_menu:                      false,
    copyable:                          false,
    expiration_container:              true
  )

  VALID_DOMAIN_REGEXP = /\A((?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel|local)|localhost)\z/i

  validates_presence_of   :original_domain,                   unless: Proc.new { |s| s.parent.blank? }
  validates_format_of     :domain, with: VALID_DOMAIN_REGEXP, unless: Proc.new { |s| s.original_domain.nil? }
  validates_uniqueness_of :domain, case_sensitive: false,     unless: Proc.new { |s| s.original_domain.nil? }

  validates_format_of     :analytics_code, allow_nil: true, with: /\A(|UA-\d*-\d*)\z/i

  validate :ensure_parent_is_root

  def self.find_by_domain(domain)
    domain ||= ''
    parts = domain.split('.')
    parts.shift if parts.first == 'www'
    domain = parts.join('.')
    Site.includes(:node).references(:nodes).where('LOWER(sections.domain) = LOWER(?) OR LOWER(sections.domain) = LOWER(?)', domain, 'www.' + domain).first || Node.root.content
  end

  def original_domain
    self.read_attribute(:domain)
  end

  def domain
    original_domain || Settler[:host]
  end

  def top_level_menu_nodes
    node.children.accessible.is_public.shown_in_menu
  end

  protected

  def ensure_parent_is_root
    errors.add(:base, :parent_must_be_root_or_not_a_site) if parent && !parent.root?
  end
end
