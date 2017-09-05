module HeadHelper
  def canonical_link
    if (includes_params_excluded_from_canonical? || @show_canonical) && canonical_url
      tag(:link, rel: 'canonical', href: canonical_url)
    end
  end

  def canonical_url
    if @node.present? && defined?(request) && request.present?
      @canonical_url ||= content_node_url(@node, params.except(:controller, :action, :id).except(*params_excluded_from_canonical).merge(host: request.host))
    end
  end

  def params_excluded_from_canonical
    [:layout, :contrast]
  end

  def includes_params_excluded_from_canonical?
    params_excluded_from_canonical.select { |p| params[p] }.any?
  end
end
