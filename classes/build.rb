module Build
	def self.configure_make
		lambda do |library, options|
			env = {}

			[:CC, :CXX, :AR, :CFLAGS, :CPPFLAGS, :LDFLAGS, :WINDRES].each do |var|
				value = options[var]
				if value.length > 0 then
					env[var.to_s] = value.join(' ')
				end
			end
			# FIXME : Allow "other" environment variables to be added... OR make everything work the same way...
			#buildCommand += "#{options.environment.join(' ')} "

			buildCommand = []
			buildCommand << "./configure"
			buildCommand.push *(options.configureOptions)
			buildCommand << "--prefix=#{options.prefix.join}"
			puts buildCommand
			Exec.run(env, *buildCommand) or raise "./configure failed."
			Exec.run(env, "make") or raise "make failed"
		end
	end
end
