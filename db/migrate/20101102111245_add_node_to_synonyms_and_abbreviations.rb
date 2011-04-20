class AddNodeToSynonymsAndAbbreviations < ActiveRecord::Migration
  def self.up
    add_column :synonyms,      :node_id, :integer
    add_column :abbreviations, :node_id, :integer

    if Node.count > 0
      Synonym.update_all(:node_id => Node.root.id)
      Abbreviation.update_all(:node_id => Node.root.id)
    end
  end

  def self.down
    remove_column :synonyms,      :node_id
    remove_column :abbreviations, :node_id
  end
end
