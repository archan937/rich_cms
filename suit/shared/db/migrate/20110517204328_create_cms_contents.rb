class CreateCmsContents < ActiveRecord::Migration
  def self.up
    create_table :cms_contents, :id => false do |t|
      t.string :key
      t.text   :value
    end
  end

  def self.down
    drop_table :cms_contents
  end
end