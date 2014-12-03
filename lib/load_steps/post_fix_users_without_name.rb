require 'load_steps/load_helpers'
require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'constants'

class PostFixUsersWithoutName < LoadStep
  def name
    'Mediate records of users without names'
  end

  def execute(*)
    # Iterate through each company
    users = User.find_by_sql('select id, login from  users u where u.name is null;')
    users.each do | record |
      User.update(record.id, name: record.login)
    end
  end

  def revert
  end
end
