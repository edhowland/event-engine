eng=EventEngine::Engine.new
@evals=["e.on_file {|ev| @last_stdout << \"file \#{ev.to_s}\\n\"}", "e.on_directory {|ev| puts \"in dir\"; @last_stdout <<  \"directory  \#{ev.to_s}\\n\"}"]
eng.setup do
  @evals.each {|v| eval v}
end