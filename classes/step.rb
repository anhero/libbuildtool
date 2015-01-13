module LBT
	# Step class.
	class Step
		# Owner library. Needs to be set.
		@library = nil

		# The subclass' initialize method can be used to add other
		# accessors used internally.

		# This method needs to be implemented by a subclass.
		def run *args
			raise "Step#run() Not Implemented for #{self.class}"
		end

		def set_owner library
			@library = library
		end
	end

	# A special step that does nothing.
	# Special care should be used to hide them when running steps,
	# they would be an eyesore otherwise!
	class NoOp < Step
		def initialize() end
		def run(*args) end
	end
end

module StepMaker

	# Makes an anonymous class and instance of class thereof
	# that can be used used as a step, with the run method
	# executing the block inside its scope.
	def make_step(&block)
		anonymous_class = Class.new(LBT::Step) do
			@@block = block
			def run
				return instance_exec(&@@block)
			end
		end
		anonymous_class.new
	end
end
