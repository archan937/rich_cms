class CreateCustomCmsContents < ActiveRecord::Migration
  def self.up
    create_table :custom_cms_contents do |t|
      t.string :custom_key
      t.text   :custom_value
      t.timestamps
    end

    add_index :custom_cms_contents, :custom_key
  end

  def self.down
    drop_table :custom_cms_contents
  end
end