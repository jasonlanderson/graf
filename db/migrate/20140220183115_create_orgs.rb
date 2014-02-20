class CreateOrgs < ActiveRecord::Migration
  def change
    create_table :orgs do |t|
      t.integer :git_id
      t.string :login
      t.string :name
      t.date :date_created
      t.date :date_updated
      t.string :source

      t.timestamps
    end
  end
end
