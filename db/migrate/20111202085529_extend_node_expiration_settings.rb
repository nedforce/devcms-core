class ExtendNodeExpirationSettings < ActiveRecord::Migration
  def up
    add_column :sections, :expiration_email_body,    :text
    add_column :sections, :expiration_email_subject, :string

    add_column :nodes, :expiration_notification_method, :string, default: 'inherit'
    add_column :nodes, :expiration_email_recipient,     :string

    Site.reset_column_information
    Node.reset_column_information
    Node.root.content.update_attributes(expiration_email_subject: 'Content onder uw beheer is verouderd', expiration_email_body: "<p>De onderstaande pagina is al enige tijd niet meer bijgewerkt en is inmiddels verlopen.</p><p>Gelieve de inhoud van deze pagina's te controleren en bij te werken.</p><p>Neem voor meer informatie contact op met de webredactie.</p>") if Node.unscoped.count > 0 && Node.roots.present?
  end

  def down
    remove_column :sections, :expiration_email_body
    remove_column :sections, :expiration_email_subject

    remove_column :nodes, :expiration_notification_method
    remove_column :nodes, :expiration_email_recipient
  end
end
