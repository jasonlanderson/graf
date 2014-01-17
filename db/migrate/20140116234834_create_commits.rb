class CreateCommits < ActiveRecord::Migration
  def change
    create_table :commits do |t|
      t.references :repo, index: true
      t.string :sha
      t.string :message
      t.date :date_created
      t.datetime :created_at
      t.datetime :updated_at

      t.timestamps
    end
  end
end
