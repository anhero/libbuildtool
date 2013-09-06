class Install
	def self.make_install
		lambda do |library, options|
			system("make install")
		end
	end

	def self.copyHeaders
		lambda do |library, options|
			FileUtils.mkdir_p "#{options.prefix}/include"
			failed = false
			headers = []
			headers += Dir.glob('**/*.h')
			headers += Dir.glob('**/**.hpp')
			headers.each do |header|
				#failed ||= (not system("cp -prf #{header} #{options.prefix}/include"))
				dest = "#{options.prefix}/include/#{header}"
				FileUtils.mkdir_p File.dirname dest
				FileUtils.copy_file header, "#{options.prefix}/include/#{header}"
			end
			return (not failed)
		end
	end
end