require 'load_steps/load_step'
require 'octokit_utils'
require 'log_level'
require 'constants'

class InitialLoad < LoadStep

  def name
    "Initial Load"
  end

  def execute(*args)
    puts "Start Step: #{name}"

    execute_load_steps(Constants::LOAD_STEPS_INITIAL)
    #execute_load_steps(Constants::LOAD_STEPS_DELTA) # TODO, remove this
    puts "Finish Step: #{name}"
  end

  def revert

  end
end