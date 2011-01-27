xml.results do
  xml.tag!('total_count', @approvals_count)
  xml.approvals do
    @approvals.each do |approval|
      xml.approval {
        xml.node_id(approval.id)
        xml.content_type(approval.content_class.human_name)
        xml.title(approval.content.content_title)
        xml.edited_by(approval.editor.nil? ? I18n.t('approvals.unknown_user') : approval.editor.login)        
        xml.updated_at(approval.updated_at.strftime("%d-%m-%Y"))
        xml.status(I18n.t(approval.status.to_sym, :scope => :approvals))
        xml.editor_comment(approval.editor_comment)
      }
    end
  end
end