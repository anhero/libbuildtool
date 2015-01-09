require 'ostruct'

# ArrayStruct
#
# Basically an OpenStruct that defaults to putting all member values as arrays.
# Defining a value using '=' will replace the array.
# Appending will automagically work, even if the value is not initialized.
#
# When you want to build a string value from the the appended values, it is
# recommended to .join() them with a proper separator.
#
# There is one issue though. Since it does some magical wrapping to an array, when
# you want to initialize an array of arrays, it is recommended to do
#
#    myas = ArrayStruct.new
#    myas.prop = []
#    myas.prop << ['val', 'val']
#
# As doing
#
#    myas = ArrayStruct.new
#    myas.prop = ['val', 'val']
#
# Would initialize prop as ['val', 'val'] instead of [ ['val', 'val'] ]
#
# On initialization (ArrayStruct.new()) with a hash, this issue would not happen.
#
#    myas = ArrayStruct.new(:prop => [ 'val', 'val' ])
#    myas.prop
#    => [ [ 'val', 'val' ] ]

class ArrayStruct < OpenStruct

	def initialize(hash=nil)
		@table = {}
		if hash
			for k,v in hash
				@table[k.to_sym] = [ v ]
				new_ostruct_member(k)
			end
		end
	end

	def method_missing(mid, *args) # :nodoc:
		mname = mid.id2name
		len = args.length
		if mname.chomp!('=') && mid != :[]=
			if len != 1
				raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
			end
			val = args[0]
			#Automatically wrap in an array, unless it is an array
			if not val.is_a?(Array) then
				val = [val]
			end
			modifiable[new_ostruct_member(mname)] = val
		elsif len == 0 && mid != :[]
			if @table[mid].nil? then
				@table[mid] = []
			end
			@table[mid]
		else
			raise NoMethodError, "undefined method `#{mid}' for #{self}", caller(1)
		end
	end

	def new_ostruct_member(name)
	  name = name.to_sym
	  unless respond_to?(name)
		define_singleton_method(name) { @table[name] }
		define_singleton_method("#{name}=") { |x| modifiable[name] = x }
	  end
	  name
	end

	def [](name)
		if @table[name].nil? then
			@table[name] = []
		end
		@table[name]
	end
end
