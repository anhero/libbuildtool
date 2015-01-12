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
#
# As we have a custom use-case of those arraystructs, we need them to have a custom
# behaviour with regards to the sub-elements.
#
#   * It needs to .to_s as a space separated string of the elements.
#   * .to_s(arg) is aliased to .join(arg)

class ArrayStructElement < Array
	def initialize(*val)
		# With a val=nil default value we would initialize with a phantom nil
		# This gets the actual count of arguments passed.
		return if val.length == 0

		# We, though, do not support more than one argument for now...
		raise "Not-implemented multiple values ArrayStructElement constructor" if val.length > 1

		# This is why we can "hack" our way around and get the first element of the array.
		val = val[0]

		# We unpack a passed array into self<< since it is the defaut expected
		# behaviour of an Array (I believe).
		if val.is_a? Array then
			val.each do |subval|
				self << subval
			end
		# Otherwise, we set the value passed as the first element.
		else
			self << val
		end
	end

	def to_s(arg=' ')
		self.join(arg)
	end
end

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
			#Automatically wrap in an ArrayStrucElement, unless it is an ArrayStructElement
			if not val.is_a?(ArrayStructElement) then
				val = ArrayStructElement.new(val)
			end
			modifiable[new_ostruct_member(mname)] = val
		elsif len == 0 && mid != :[]
			self[mid]
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
			@table[name] = ArrayStructElement.new()
		end
		@table[name]
	end
end
