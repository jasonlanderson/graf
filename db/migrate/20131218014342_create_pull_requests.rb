class CreatePullRequests < ActiveRecord::Migration
  def change
    create_table :pull_requests do |t|
      t.references :repo, index: true
      t.references :user, index: true
      t.integer :git_id
      t.integer :pr_number
      t.text :body
      t.string :title
      t.string :state
      t.date :date_created
      t.date :date_closed
      t.date :date_updated
      t.date :date_merged

      t.timestamps
    end
  end
end
