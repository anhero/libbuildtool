# LBT::Steps holds a collectionf of steps.
#
# It proxies some of the methods to its internal array.
# Don't be shy adding more proxies if needed, and intelligent.
#
# TODO : Add insert that inserts after or before a specific step name.
#
class LBT::Steps
	def initialize
		@steps = []
	end

	def find name
		unless name.is_a? Symbol
			name = name.to_sym
		end

		@steps.each do |step|
			return step[:instance] if step[:name] == name
		end
	end

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

	def <<(step)
		unless replace step
			@steps << step
		end
	end

	def select &block
		@steps.select &block
	end
	def each &block
		@steps.each &block
	end
	def count
		@steps.count
	end

end

