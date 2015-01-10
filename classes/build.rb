module Build
	def self.configure_make
		lambda do |library, options|
			Dir.chdir "#{library.work_dir}/#{library.build_subdir}"
			env = {}
			[:CC, :CXX, :AR, :CFLAGS, :CPPFLAGS, :LDFLAGS, :WINDRES].each do |var|
				value = options[var]
				if value.length > 0 then
					env[var.to_s] = value.join(' ')
				end
			end
			# FIXME : Allow "other" environment variables to be added... OR make everything work the same way...
			#build_command += "#{options.environment.join(' ')} "

			build_command = []
			build_command << "./configure"
			build_command.push *(options.configure_options)
			build_command << "--prefix=#{options.prefix.join}"
			puts build_command
			Exec.run(env, *build_command) or raise "./configure failed."
			Exec.run(env, "make") or raise "make failed"
		end
	end
end
