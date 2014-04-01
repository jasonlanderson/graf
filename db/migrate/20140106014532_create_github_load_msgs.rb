class CreateGithubLoadMsgs < ActiveRecord::Migration
  def change
    create_table :github_load_msgs do |t|
      t.references :github_load, index: true
      t.text :msg
      t.integer :log_level
      t.datetime :log_date

      t.timestamps
    end
  end
end
