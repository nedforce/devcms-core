xml.results do
  xml.tag!('total_count', @versions_count)
  xml.versions do
    @versions.each do |version|
      xml.version {
        xml.id(version.id)
        xml.node_id(version.versionable.node.id)
        xml.content_type(version.versionable.class.human_name)
        xml.title(version.versionable.current_version.title)
        xml.edited_by(version.editor.login)        
        xml.updated_at(version.created_at.strftime("%d-%m-%Y"))
        xml.status(I18n.t(version.status.to_sym, :scope => :approvals))
        xml.editor_comment(version.editor_comment)
      }
    end
  end
end