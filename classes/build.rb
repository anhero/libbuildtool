module Build
	def self.configure_make
		lambda do |library, options|
			Dir.chdir "#{library.work_dir}/#{library.build_subdir}"

			buildCommand = ""

			[:CC, :CXX, :AR, :CFLAGS, :CPPFLAGS, :LDFLAGS, :WINDRES].each do |env|
				value = options[env]
				if value.length > 0 then
					buildCommand += "#{env}=\"#{value.join(' ')}\""
				end
			end

			buildCommand += "#{options.environment.join(' ')} "
			buildCommand += "./configure #{options.configureOptions.join(' ')} --prefix=#{options.prefix.join} && make"
			puts buildCommand
			system(buildCommand)
		end
	end
end
