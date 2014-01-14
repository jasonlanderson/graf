	class CreateCommitsUsers < ActiveRecord::Migration
	  def change
	  	 create_table :commits_users, :id => false do |t|
	  	 	#t.references :commit
	  	 	#t.references :user
	  	 	t.belongs_to :commit
	  	 	t.belongs_to :user
	  	 end
	  end
	end
