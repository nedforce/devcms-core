module DevcmsCore
  class Rewriter < Rack::Rewrite
    def initialize(app, &rule_block)
      super(app, &rule_block)
      DevcmsCore::Engine.config.rewriter = self
    end

    def append(&rule_block)
      @rule_set.instance_eval(&rule_block)
    end
  end
end
