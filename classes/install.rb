class Install
	def self.make_install
		lambda do |library, options|
			system("make install")
		end
	end

	def self.copyHeaders
		lambda do |library, options|
			FileUtils.mkdir_p "#{options.prefix.join}/include"
			headers = []
			headers += Dir.glob('**/*.h')
			headers += Dir.glob('**/**.hpp')
			headers.each do |header|
				dest = "#{options.prefix.join}/include/#{header}"
				FileUtils.mkdir_p File.dirname dest
				FileUtils.rm dest if File.exist? dest
				FileUtils.cp header, dest
			end
		end
	end
end
