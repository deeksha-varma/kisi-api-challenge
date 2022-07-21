class HelloJob < ActiveJob::Base
  def perform(name)
    puts "Heloooooooo...#{name}"
  end
end
