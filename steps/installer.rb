class Installer < LBT::StepsFabricator
	class MakeInstall < LBT::Step
		def run
			Dir.chdir "#{@library.work_dir}/#{@library.build_subdir}"
			Exec.run("make", "install")
		end
	end

	class CopyHeaders < LBT::Step
		def initialize options
			@options = options
		end
		def run
			Dir.chdir "#{@library.work_dir}/#{@library.build_subdir}"
			FileUtils.mkdir_p "#{@options.prefix.join}/include"
			headers = []
			headers += Dir.glob('**/*.h')
			headers += Dir.glob('**/**.hpp')
			headers.each do |header|
				dest = "#{@options.prefix.join}/include/#{header}"
				FileUtils.mkdir_p File.dirname dest
				FileUtils.rm dest if File.exist? dest
				FileUtils.cp header, dest
			end
		end
	end
end
