module LBT
	# For Fetcher, Verifier, etc...
	# Subclasses will automagically have a magic constructor.
	#
	# A subclass will be implemented as such:
	#
	# class Foobarer < LBT::StepsFabricator
	# 	class BazBar
	# 		def initialize fizz
	# 			@fizz = fizz
	# 		end
	# 		def run
	# 			# Do whatever
	# 			puts @fizz
	# 		end
	# 	end
	# end
	#
	# And used as such:
	#
	# library.foobarer = Foobarer::BazBar("buzz")
	#
	# The magic constructor will call BazBar.new().
	#
	# This is not your usual Ruby, but is used to make a DSL.
	#
	class StepsFabricator
		def self.method_missing(method, *args)
			unless self.constants.include? method
				raise "#{self.name}::#{method} not found."
			end
			self.const_get(method).new(*args)
		end
	end
end

