# Steps generally used to build software and libraries.
class Steps::Builder < LBT::StepsFabricator

	# Builds using a +./configure && make+ -like pipeline.
	#
	# Uses properties of +library.options+.
	#
	# Those properties will be used as environment.
	# * +CC+
	# * +CXX+
	# * +AR+
	# * +CFLAGS+
	# * +CPPFLAGS+
	# * +LDFLAGS+
	# * +WINDRES+
	#
	# The +library.options.configure_options+ +Array+ will be used as parameters
	# to the +./configure+ command.
	#
	# The +library.options.install_dir+ will be used as +PREFIX+.
	#
	# Will +raise+ if +./configure+ or +make+ fails.
	#
	# @see Installer::MakeInstall
	class ConfigureMake < LBT::Step
		def run
			Dir.chdir "#{@library.work_dir}/#{@library.build_subdir}"
			env = {}
			[:CC, :CXX, :AR, :CFLAGS, :CPPFLAGS, :LDFLAGS, :WINDRES].each do |var|
				value = @library.options[var]
				if value.length > 0 then
					env[var.to_s] = value.join(' ')
				end
			end
			# FIXME : Allow "other" environment variables to be added... OR make everything work the same way...
			#build_command += "#{@options.environment.join(' ')} "

			build_command = []
			build_command << "./configure"
			build_command.push *(@library.options.configure_options)
			build_command << "--prefix=#{@library.options.install_dir.join}"
			puts build_command
			Exec.run(env, *build_command) or raise "./configure failed."
			Exec.run(env, "make") or raise "make failed"
		end
	end

end
