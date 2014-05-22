module Build
	def self.configure_make
		lambda do |library, options|
			buildCommand = ""
			buildCommand += "CC=\"#{options.CC}\" " if defined? options.CC
			buildCommand += "CXX=\"#{options.CXX}\" " if defined? options.CXX
			buildCommand += "AR=\"#{options.AR}\" " if defined? options.AR
			buildCommand += "CFLAGS=\"#{options.CFLAGS}\" " if defined? options.CFLAGS
			buildCommand += "CPPFLAGS=\"#{options.CPPFLAGS}\" " if defined? options.CPPFLAGS
			buildCommand += "LDFLAGS=\"#{options.LDFLAGS}\" " if defined? options.LDFLAGS
			buildCommand += "WINDRES=\"#{options.WINDRES}\" " if defined? options.WINDRES

			buildCommand += "#{options.environment} " if defined? options.environment
			buildCommand += "LIBTOOL=ranlib ./configure #{options.configureOptions} --prefix=#{options.prefix} && make"
			puts buildCommand
			system(buildCommand)
		end
	end
end