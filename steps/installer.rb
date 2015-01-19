# Steps generally used to install software or libraries.
class Steps::Installer < LBT::StepsFabricator

	# Installs using the common +make install+.
	#
	# It simply calls +make install+
	# Proper configuration for +make install+ should be done in a prior +Step+,
	# generally +Builder::ConfigureMake+
	#
	# @see Builder::ConfigureMake
	class MakeInstall < LBT::Step
		# Runs the step
		# @return [void]
		def run
			@library.options.build_dir = "#{@library.work_dir}/#{@library.build_subdir}" if @library.options.build_dir.empty?
			Dir.chdir @library.options.build_dir.join
			Exec.run("make", "install")
		end
	end

	# Installs by copying +.h + and +.hpp+ files to the +install_dir+, keeping
	# the subtree structure
	#
	# Uses +library.options.install_dir+ as the target path.
	#
	class CopyHeaders < LBT::Step
		# Runs the step
		# @return [void]
		def run
			@library.options.build_dir = "#{@library.work_dir}/#{@library.build_subdir}" if @library.options.build_dir.empty?
			Dir.chdir @library.options.build_dir.join
			FileUtils.mkdir_p "#{@library.options.install_dir.join}/include"
			headers = []
			headers += Dir.glob('**/*.h')
			headers += Dir.glob('**/**.hpp')
			headers.each do |header|
				dest = "#{@library.options.install_dir.join}/include/#{header}"
				FileUtils.mkdir_p File.dirname dest
				FileUtils.rm dest if File.exist? dest
				FileUtils.cp header, dest
			end
		end
	end
end
