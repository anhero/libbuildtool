module LBT
	# A step in the build process of a library.
	#
	# An instance has a +Library+ associated with the step to query to get
	# informations about siad library.
	#
	# It is important to implement the +run+ method, the default raises.
	#
	# @see Step#run
	class Step
		# Owner library. Needs to be set.
		@library = nil

		# A new instance of Step
		#
		# The subclass' initialize method can be used to add other
		# accessors used internally by passing parameters on construction.
		#
		# By default, does nothing.
		#
		# @see Verifier::Hash Verifier::Hash for an example of custum constructor.
		def initialize() end

		# This method needs to be implemented by a subclass
		# 
		# The +run+ method's output value is not used.
		# If +run+ fails, +raise+ should be used.
		#
		#     def run
		#       Exec.run("false") or raise "An issue happened while running false."
		#     end
		#
		# @return [void]
		def run *args
			raise "Step#run() Not Implemented for #{self.class}"
		end

		# Used by the +Library+ to add itself to the step's scope
		#
		# This allows the step to use +@library+.
		#
		# @param library [Library] +Library+ that owns this +Step+
		#
		# @return [Object] Passed value
		def set_owner library
			@library = library
		end

		# Defines whether the step should be run
		# 
		# Defaults to +true+.
		# 
		# Used mainly to hide steps that are doing nothing.
		#
		# @return [Boolean] true as default.
		def should_run
			return true
		end
	end

	# A special step that does nothing
	#
	# Special care should be used to hide them when running steps,
	# they would be an eyesore otherwise!
	class NoOp < Step
		# Does nothing if ran
		#
		# @return [void]
		def run(*args) end
		# Tells +libbuildtool+ not to run this step
		#
		# @return false
		def should_run() return false end
	end
end

# Namespace for make_step, should be included in global scope
module LBT::StepMaker

	# Shortcut to make a one-off step
	#
	# Makes an anonymous +Class+ inheriting +Step+, and instance of 
	# +class+ thereof that can be used used as a +Step+, 
	# with the run method executing the block passed inside its scope.
	#
	# The block passed will have access to the internals of +Step+,
	# making +@library+ available.
	#
	# @example
	#   library.builder = make_step do
	#     Dir.chdir "#{@library.work_dir}/#{@library.build_subdir}"
	#     Exec.run("./build.sh")
	#   end
	#
	# Care should be taken when building a libraries list to not repeat
	# those. If you find yourself repeating the bodies of those anonymous
	# +Step+s, please implement subclassing +Step+.
	#
	# Reduce, Reuse, Recycle ♲
	#
	# @param [Proc] block Block to use for the +run+ method.
	#
	# @return [LBT::Step] Instance of +Step+ which will run passed +block+.
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
