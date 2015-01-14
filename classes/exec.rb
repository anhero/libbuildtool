#
# Exec
#
# Allows safer execution of external dependencies.
# Wraps +Process.spawn+, using proper +IO+ for +stdin/stdout/stderr+ handling.
#

class Exec

	# Shortcut for +Kernel.system()+ when +system+ is disabled
	#
	# @return See +Kernel.system+
	def self._sys(*args)
		Kernel.system(*args)
	end

	# Run external programs
	#
	# The parameters are handled in a special way, as it would for +Process.spawn()+.
	#
	# The first parameter is the program to call.
	#
	# The other parameters are the arguments for this program, which do not need to be
	# shell-escaped or shell-quoted as those parameters are not shelled-out.
	# Though, take note that the underlying program might need to have some special
	# care taken with its arguments, this is not the business of +Exec.run+.
	#
	# As a special case, a hash can be passed before parameter one, which is used
	# to build an environment and passed to the underlying process.
	#
	# Finally, options can be passed as named parameters.
	# * +:silent+   Will suppress all the output.
	# * +:stdin+    With a hash having :filename = true, will use the +:filename+ options as stdin.
	# * +:stdin+    A +String+ that will be used with an +IO.pipe()+ to send to the process as stdin.
	# * +:filename+ To be used by stdin as input.
	#
	# @see Exec.program_exists program_exists for an example.
	#
	# *Note:* Currently, passing only one +String+ to this function will follow the
	# convention that +Process.spawn()+ uses and shell out to the system's shell.
	# This is not the recommended way to use Exec.run and is not supported. It, though,
	# will not be disabled explicitely unless reasons requires it.
	#
	# @return true when command is successful (0 return value).
	# @return false otherwise.
	def self.run(*args)#, **options)

		# Options hash
		options = {}
		if args.last.is_a? Hash then
			options = args.pop
		end

		# Environment pre-pend
		env = {}
		if args.first.is_a? Hash then
			env = args.shift
		end

		spawn_options = {}

		if options[:silent] then
			spawn_options[:err] = '/dev/null'
			spawn_options[:out] = '/dev/null'
		end

		if options[:stdin] then
			if options[:stdin].is_a? Hash then
				if options[:stdin][:filename] == true then
					spawn_options[:in] = options[:filename]
				else
					raise "Other stdin options are not yet implemented."
				end
			else
				stdin_r, stdin_w = IO.pipe()
				spawn_options[:in] = stdin_r
				stdin_w.write(options[:stdin])
				stdin_w.close
			end
		end

		# FIXME : Better output commandline
		unless options[:silent] then
			puts "$> \"#{args.join('" "')}\""
		end
		pid = Process.spawn(env, *args, spawn_options)
		Process.wait(pid)

		# Process.wait() sets $? to the exit status.
		return $? == 0
	end

	# Shortcut for system's +which+ command
	#
	# @return +true+ if the program is available.
	# @return +false+ otherwise.
	def self.program_exists name
		Exec.run "which", name, :silent=>true
	end

end


# Disabling system() for safety
# We will only disable when developping stuff.
#def system(*args)
#	raise Exception.new("system() has been disabled by Exec")
#end
