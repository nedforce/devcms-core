module DevcmsCore
  class ContentNodeCheckerRunner < DataChecker::Runner
    models      *DevcmsCore::Engine.registered_content_types.map(&:constantize)
    checker     LinkChecker
    scope       lambda { |model| model.joins(:node).where('nodes.last_checked_at IS NULL OR nodes.last_checked_at < ?', 1.week.ago) }
    after_check lambda { |subject| subject.node.update_column :last_checked_at, Time.now }
  end
end
