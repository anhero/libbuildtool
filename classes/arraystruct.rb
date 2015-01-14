require 'ostruct'

# An ArrayStruct is basically an OpenStruct that defaults to putting 
# all member values as arrays.
#
# Defining a value using +=+ will replace the array.
# Appending will automagically work, even if the value is not initialized.
#
# When you want to build a string value from the the appended values, it is
# recommended to +.join()+ them with a proper separator.
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
# Would initialize +prop+ as +['val', 'val']+ instead of +[ ['val', 'val'] ]+ 
#
# On initialization +ArrayStruct.new()+ with a +Hash+, this issue would not happen.
#
#    myas = ArrayStruct.new(:prop => [ 'val', 'val' ])
#    myas.prop
#    => [ [ 'val', 'val' ] ]
#
# As we have a custom use-case of those +ArrayStruct+, we need them to have a custom
# behaviour with regards to the sub-elements.
# * It needs to +.to_s+ as a space separated string of the elements.
# * +.to_s(arg)+ is aliased to +.join(arg)+
#
# This is implemented in +ArrayStruct::ArrayStructElement+

class ArrayStruct < OpenStruct

	# Returns a new instance of ArrayStruct
	def initialize(hash=nil)
		@table = {}
		if hash
			for k,v in hash
				@table[k.to_sym] = [ v ]
				new_ostruct_member(k)
			end
		end
	end

	# Makes it possible to access members using dot notation
	#
	#    myas = ArrayStruct.new()
	#    myas.prop = "bob"
	#    p myas.prop
	#
	#    => "bob"
	#
	# @return
	def method_missing(mid, *args)
		mname = mid.id2name
		len = args.length
		if mname.chomp!('=') && mid != :[]=
			if len != 1
				raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
			end
			# Add the new member to the defined methods.
			new_ostruct_member(mname)
			# Then use it as it has custom behaviour.
			self.send(mid, *args)
		elsif len == 0 && mid != :[]
			self[mid]
		else
			raise NoMethodError, "undefined method `#{mid}' for #{self}", caller(1)
		end
	end

	# Accesses a specific element as you would with a +Hash+
	#
	# @return [ArrayStructElement] The specific element asked for, or a new ArrayStructElement
	def [](name)
		if @table[name].nil? then
			@table[name] = ArrayStructElement.new()
		end
		@table[name]
	end

	protected
	# Used internally
	# @private
	# @return The name of the new member.
	def new_ostruct_member(name)
	  name = name.to_sym
	  unless respond_to?(name)
		define_singleton_method(name) { @table[name] }
		define_singleton_method("#{name}=") { |x| 
			#Automatically wrap in an ArrayStrucElement, unless it is an ArrayStructElement
			if not x.is_a?(ArrayStructElement) then
				x = ArrayStructElement.new(x)
			end
			modifiable[name] = x
		}
	  end
	  name
	end
end


# A specialization of +Array+ for semantic sugar
#
# It is used mainly to allow overriding its +.to_s()+ method.
#
class ArrayStruct::ArrayStructElement < Array

	# A new instance of ArrayStructElement
	#
	# It can be initialized with nothing, giving an empty array.
	#     ase = ArrayStructElement.new()
	#     p ase.count
	#     => 0
	# 
	# It can be initialized passing an array.
	#     ase = ArrayStructElement.new([1,2,3])
	#     p ase.count
	#     => 3
	#     p ase[1]
	#     => 2
	# 
	# It can also be initialized with an initial value.
	#     ase = ArrayStructElement.new("foo")
	#     p ase.count
	#     => 1
	#     p ase[0]
	#     => "bob"
	#
	# It does not mirror entirely +Array.new()+ nor does it try to exactly
	# as it should be only used internally by +ArrayStruct+. Usage outside
	# of +ArrayStruct+ is not recommended.
	#
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

	# Joins the elements of the array as a string, using space as a default separator
	#
	# When you want to use another separator for the collection, you should
	# use +.join(sep)+ on the collection, as it presents the intention better.
	#     myas.PATH << "/bin"
	#     myas.PATH << "/sbin"
	#
	#     p myas.PATH
	#     => "/bin /sbin"
	#
	#     p myas.PATH.join(":")
	#     => "/bin:/sbin"
	#
	#     # Though you could use
	#     p myas.PATH.to_s(":")
	#     => "/bin:/sbin"
	#
	# @return [String] The string representation of the ArrayStructElement.
	def to_s(arg=' ')
		self.join(arg)
	end
end
