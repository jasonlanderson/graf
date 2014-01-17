class CreateCommitsUsers < ActiveRecord::Migration
	def up
	  create_table :commits_users, :id => false do |t|
	    t.integer :commit_id, :null => false
	    t.integer :user_id, :null => false
	  end
	end

	def down
	  drop_table :commits_users
	end
end