# The Library is both the representation of the library
# and the holder of the steps needed to build it.
#
# You can pass any named parameter to .new() to have
# its properties filled.
#
# You can still fill those properties by the accessor
# just as you could before.
#
class Library
	attr_accessor :name, :version, :license,
	              :build_subdir, :work_dir, :prefix

	# Used to store and retrieve the clone of $build_options.
	attr_accessor :options

	# Used to pass the archive name between many steps.
	attr_accessor :archive, :url

	def initialize *args
		# Options hash
		options = {}
		if args.last.is_a? Hash then
			options = args.pop
		end
		options.each do |name, value|
			name = "@#{name}".to_sym
			self.instance_variable_set name, value
		end

		# This is a global state that we clone.
		@options = $build_options.clone

		@steps = LBT::Steps.new()
		# The default steps order
		[ :fetcher, :verifier, :unpacker, :patcher, :preparer, :builder, :installer ].each do |name|
			@steps << {
				name: name,
				instance: LBT::NoOp.new()
			}
		end

		# Opinionated defaults
		self.unpacker = Unpacker::Auto.new()
	end

	# Returns the steps that should run.
	def steps
		@steps.select do |step|
			step[:instance].should_run
		end
	end

	# Returns all steps, including +NoOp+s and those other that should not run.
	def all_steps
		@steps
	end

	def add_step name, v
		v.set_owner self
		@steps << {
			name: name,
			instance: v,
		}
	end

	# method_missing implements magic 'stepname'er accessors.
	def method_missing method, *args
		# to add steps magically with stepnameer = StepClass.new
		if method[-3..-1] == "er=" then
			method = method[0..-2].to_sym
			v = args.shift
			add_step method, v
		# to add steps magically with stepnameer StepClass.new
		elsif method[-2..-1] == "er" then
			return @steps.find method
		else
			super.method_missing method, *args
		end
	end
end
