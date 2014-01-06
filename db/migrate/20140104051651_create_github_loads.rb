class CreateGithubLoads < ActiveRecord::Migration
  def change
    create_table :github_loads do |t|
      t.datetime :load_start_time
      t.datetime :load_complete_time
      t.boolean :initial_load

      t.timestamps
    end
  end
end
