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
		# Runs the step
		# @return [void]
		def run
			@library.options.build_dir = "#{@library.work_dir}/#{@library.build_subdir}" if @library.options.build_dir.empty?
			Dir.chdir @library.options.build_dir.join
			env = {}
			[:CC, :CXX, :AR, :CFLAGS, :CPPFLAGS, :CXXFLAGS, :LDFLAGS,
			 :WINDRES, :PATH, :LD_LIBRARY_PATH, :LIBRARY_PATH].each do |var|
				value = @library.options[var]
				if value.length > 0 then
					env[var.to_s] = value.join(' ')
				end
			end
			# FIXME : Allow "other" environment variables to be added... OR make everything work the same way...
			#build_command += "#{@options.environment.join(' ')} "


			# Here we pass ./configure through sh because on some platforms (windos), the 
			# ./configure call does not resolve properly.
			# This might break, if it does, revert, but think of a method for platform-dependant calls.
			@library.options.CONFIGURE =  ['sh', './configure'] if @library.options.CONFIGURE.empty?

			# Wraps in an array for backwards compatibility's sake.
			unless @library.options.CONFIGURE.is_a? Array
				@library.options.CONFIGURE = [ @library.options.CONFIGURE ]
			end

			build_command = []
			build_command.push *(@library.options.CONFIGURE)
			build_command.push *(@library.options.configure_options)
			build_command << "--prefix=#{@library.options.install_dir.join}"
			Exec.run(env, *build_command) or raise "./configure failed."

			build_command = []
			build_command << "make"
			build_command.push *(@library.options.make_options)
			Exec.run(env, *build_command) or raise "make failed"
		end
	end


	class CMakeMake < LBT::Step

		def run
			@library.options.build_dir = "#{@library.work_dir}/#{@library.build_subdir}" if @library.options.build_dir.empty?
			Dir.chdir @library.options.build_dir.join
			env = {}
			[:CC, :CXX, :AR, :CFLAGS, :CPPFLAGS, :CXXFLAGS, :LDFLAGS, :WINDRES].each do |var|
				value = @library.options[var]
				if value.length > 0 then
					env[var.to_s] = value.join(' ')
				end
			end

			@library.options.CMAKE =  'cmake' if @library.options.CMAKE.empty?
			@library.options.CMAKE_DIR = '.' if @library.options.CMAKE_DIR.empty?
			@library.options.CMAKE_BUILD_TYPE =  'MinSizeRel' if @library.options.CMAKE_BUILD_TYPE.empty?

			cmake_build_type = @library.options.CMAKE_BUILD_TYPE || "MinSizeRel"

			build_command = []
			build_command << @library.options.CMAKE.join
			build_command << '-G'
			build_command << 'Unix Makefiles'
			build_command.push *(@library.options.cmake_options)
			build_command << "-DCMAKE_PREFIX_PATH=#{@library.options.install_dir}"
			build_command << "-DCMAKE_INSTALL_PREFIX=#{@library.options.install_dir}"
			build_command << "-DCMAKE_BUILD_TYPE=#{@library.options.CMAKE_BUILD_TYPE}"
			build_command << "#{@library.options.CMAKE_DIR}"

			puts build_command
			Exec.run(env, *build_command) or raise "cmake failed."

			build_command = []
			build_command << "make"
			build_command.push *(@library.options.make_options)
			Exec.run(env, *build_command) or raise "make failed"
		end
	end

end
