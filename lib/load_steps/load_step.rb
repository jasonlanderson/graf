class LoadStep
  def name
    "***NEED TO SET STEP NAME***"
  end


  def execute(*args)
    #raise ArgumentError, "Too much arguments" if args.length > 2
    #var = *args[0]
    puts "Start Step: #{name}"


    puts "Finish Step: #{name}"    
  end

  def revert

  end

  def execute_load_steps(steps)
    steps.each { |step|
      step.execute
    }
  end
end