class PullRequest < ActiveRecord::Base
  belongs_to :repo
  belongs_to :user
  #attr_accessible :repo_id, :user_id, :git_id, :pr_number, :body, :title, :state, :date_created, :date_closed, :date_updated, :date_merged

  # TODO: Fix this since the function doesn't work
  # def days_open

  #   if date_closed
  #     end_time =  date_closed.to_datetime
  #   else
  #     end_time = Time.now
  #   end

  #   puts "end_time #{end_time} - date_created #{date_created}"
  #   end_time - date_created.to_datetime
  # end

end
