module Build
	def self.configure_make
		lambda do |library, options|
			system("./configure --prefix=#{options.prefix} && make")
		end
	end
end