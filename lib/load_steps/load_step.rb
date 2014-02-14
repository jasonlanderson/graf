require 'octokit_utils'
require 'log_level'

class LoadStep
  def name
    "***NEED TO SET STEP NAME***"
  end


  def execute(*args)
    #raise ArgumentError, "Too many arguments" if args.length > 2
    #var = args[0]
    puts "***NEED TO SET STEP EXECUTE***"  
  end

  def revert

  end

  def execute_load_steps(steps)
    steps.each { |step|
      step.execute
    }
  end
end