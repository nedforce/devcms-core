class AddNodeToSynonymsAndAbbreviations < ActiveRecord::Migration
  def up
    add_column :synonyms,      :node_id, :integer
    add_column :abbreviations, :node_id, :integer

    Node.reset_column_information
    Synonym.reset_column_information
    Abbreviation.reset_column_information

    if Node.unscoped.count > 0
      Synonym.update_all(node_id: Node.root.id)
      Abbreviation.update_all(node_id: Node.root.id)
    end
  end

  def down
    remove_column :synonyms,      :node_id
    remove_column :abbreviations, :node_id
  end
end
