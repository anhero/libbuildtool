module LBT
	# Step class.
	class Step
		# Owner library. Needs to be set.
		@library = nil

		# The subclass' initialize method can be used to add other
		# accessors used internally.

		# This method needs to be implemented by a subclass.
		# 
		# The +run+ method's output value is not used.
		# If +run+ fails, +raise+ should be used.
		#
		#     def run
		#       Exec.run("false") or raise "An issue happened while running false."
		#     end
		def run *args
			raise "Step#run() Not Implemented for #{self.class}"
		end

		# Used by the library to add itself to the step's scope.
		#
		# This allows the step to use @library.
		def set_owner library
			@library = library
		end

		# Defines whether the step should be run.
		# 
		# Defaults to true.
		# 
		# Used mainly to hide steps that are doing nothing.
		def should_run
			return true
		end
	end

	# A special step that does nothing.
	# Special care should be used to hide them when running steps,
	# they would be an eyesore otherwise!
	class NoOp < Step
		def initialize() end
		def run(*args) end
		def should_run() return false end
	end
end

module LBT::StepMaker

	# Makes an anonymous class and instance of class thereof
	# that can be used used as a step, with the run method
	# executing the block inside its scope.
	def make_step(&block)
		anonymous_class = Class.new(LBT::Step) do
			def initialize block
				@block = block
			end
			def run
				instance_exec &@block
			end
		end
		anonymous_class.new block
	end
end

# Used for semantic holding of classes of +Step+s.
#
# This should be included in the scope where Libraries are built.
module Steps

end
