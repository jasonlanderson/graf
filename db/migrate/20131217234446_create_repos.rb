class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.integer :git_id
      t.string :name
      t.string :full_name
      t.boolean :fork
      t.date :date_created
      t.date :date_updated
      t.date :date_pushed

      t.timestamps
    end
  end
end
