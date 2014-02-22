class CreateOrgs < ActiveRecord::Migration
  def change
    create_table :orgs do |t|
      t.integer :git_id
      t.string :login
      t.string :name
      t.string :type
      t.date :date_created
      t.date :date_updated

      t.timestamps
    end
  end
end
