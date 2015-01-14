# Holds a collection of +Step+s.
#
# It proxies some of the methods to its internal +Array+.
# Don't be shy adding more proxies if needed, and intelligent.
#
# @todo Add insert that inserts after or before a specific step name.
#
class LBT::Steps

	# A new instance of Steps collection
	def initialize
		@steps = []
	end

	# Finds a +step+ by its name
	#
	# The name passed should be a symbol, but an explicit conversion is used.
	#
	# @return The +Step+
	def find name
		unless name.is_a? Symbol
			name = name.to_sym
		end

		@steps.each do |step|
			return step[:instance] if step[:name] == name
		end
	end

	# Tries to replace a +Step+ by another +Step+ with the same +:name+
	#
	# @return +true+  if successfully replaced the +Step+.
	# @return +false+ if the +Step+ was not found.
	def replace newstep
		replaced = false
		@steps.map! do |step|
			if step[:name] == newstep[:name] then
				step = newstep
				replaced = true
			end
			step
		end
		return replaced
	end

	# Replaces or appends a +Step+
	#
	# It will replace the step if +#replace+ can replace it.
	# Otherwise, it will append to its internal array.
	#
	# @return [LBT::Steps] Reference to self to allow chaining.
	def <<(step)
		unless replace step
			@steps << step
		end

		self
	end

	# Proxies to +@steps.select+
	#
	# @return [Array]
	def select &block
		@steps.select &block
	end
	# Proxies to +@steps.each+
	#
	# @return [Array]
	def each &block
		@steps.each &block
	end
	# Proxies to +@steps.count+
	#
	# @return [int]
	def count
		@steps.count
	end

end

