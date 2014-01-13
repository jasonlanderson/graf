class Commits < ActiveRecord::Migration
  def change
  	create_table :commits do |t|
    t.integer  :repo_id
    t.integer  :user_id
    t.string   :sha
    t.string   :message
    t.date     :date
  end
  end
end
