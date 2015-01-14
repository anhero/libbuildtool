module LBT
	# Holds +Step+ subclasses and allows a magic constructor to be used
	#
	# For +Fetcher+, +Verifier+, etc...
	#
	# Subclasses will automagically have a magic constructor.
	#
	# A subclass will be implemented as such:
	#
	#   class Foobarer < LBT::StepsFabricator
	#       class BazBar < LBT::Step
	#           def initialize fizz
	#               @fizz = fizz
	#           end
	#           def run
	#               # Do whatever
	#               puts @fizz
	#           end
	#       end
	#   end
	#
	# And used as such:
	#
	#   library.foobarer = Foobarer::BazBar("buzz")
	# or
	#   library.foobarer = Foobarer::BazBar "buzz"
	#
	# The magic constructor will call +BazBar.new()+.
	#
	# This is not your idiomatic Ruby, but is used to make a DSL.
	#
	# @see Step Step for more informations about Steps.
	class StepsFabricator

		# Implements the magic constructor
		#
		# @return [LBT::Step] Instance of step according to the name used.
		def self.method_missing(method, *args)
			unless self.constants.include? method
				raise "#{self.name}::#{method} not found."
			end
			self.const_get(method).new(*args)
		end
	end
end

