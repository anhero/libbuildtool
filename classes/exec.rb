#
# Exec
#
# Allows safer execution of external dependencies.
# Wraps Process.spawn, using proper IO for stdin/stdout/stderr handling.
#

class Exec

	# Not to be used. Only here as a shortcut for tests
	def self._sys(*args)
		Kernel.system(*args)
	end

	# Shortcut to run stuff. returns true when command is successful (0 return value)
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

end


# Disabling system() for safety
# We will only disable when developping stuff.
#def system(*args)
#	raise Exception.new("system() has been disabled by Exec")
#end
