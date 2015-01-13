require 'ostruct'

# Holds the Library classes.
module Libraries end

# The non-opinionated Library.
#
# The Library is both the representation of the library
# and the holder of the steps needed to build it.
#
# You can pass any named parameter to .new() to have
# its properties filled.
#
# You can fill any field through their accessor as you
# would an OpenStruct.
#
class Libraries::BaseLibrary < OpenStruct
	attr_accessor :options

	def initialize *args
		super *args

		# This is a global state that we clone.
		@options = $build_options.clone
	end

	# Accesses a specific element as you would with a +Hash+
	def [](name)
		if @table[name].nil? then
			@table[name] = ArrayStructElement.new()
		end
		@table[name]
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
			super method, *args
		end
	end
end

# An opinionated +Library+ with default values and behaviour.
#
# This +Library+ defines some default steps, which have a particular order.
# 
# Some automatic steps are added as defaults for some of the steps.
# * +Fetcher::Auto+
# * +Unpacker::Auto+
#
# @see Fetcher::Auto
# @see Unpacker::Auto
#
# Some accessors have special meaning for those steps
# * +library.url+
# * +library.path+
# * +library.archive+
# 
# Those steps should cover the basic needs for most of the Libraries you want
# to build.
#
# @see Libraries::BaseLibrary
class Libraries::Library < Libraries::BaseLibrary

	def initialize *args
		super *args

		@steps = LBT::Steps.new()
		# The default steps order
		[ :fetcher, :verifier, :unpacker, :patcher, :preparer, :builder, :installer ].each do |name|
			@steps << {
				name: name,
				instance: LBT::NoOp.new()
			}
		end

		# Opinionated defaults
		self.fetcher  = Fetcher::Auto.new()
		self.unpacker = Unpacker::Auto.new()
	end
end

# Adds the Library classes to the global scope.
include Libraries
