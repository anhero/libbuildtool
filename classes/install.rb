class Install
	def self.make_install
		lambda do |library, options|
			Dir.chdir "#{library.work_dir}/#{library.build_subdir}"

			system("make install")
		end
	end

	def self.copyHeaders
		lambda do |library, options|
			Dir.chdir "#{library.work_dir}/#{library.build_subdir}"

			FileUtils.mkdir_p "#{options.prefix}/include"
			failed = false
			headers = []
			headers += Dir.glob('**/*.h')
			headers += Dir.glob('**/**.hpp')
			headers.each do |header|
				#failed ||= (not system("cp -prf #{header} #{options.prefix}/include"))
				dest = "#{options.prefix}/include/#{header}"
				FileUtils.mkdir_p File.dirname dest
				FileUtils.rm "#{options.prefix}/include/#{header}" if File.exist? "#{options.prefix}/include/#{header}"
				FileUtils.cp header, "#{options.prefix}/include/#{header}"
			end
			return (not failed)
		end
	end
end