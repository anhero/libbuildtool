module Platforms

	class Platform

		attr_accessor :buildOptions
		def defaultOptions opts
			puts self

			opts.separator ''
			opts.separator "#{name} options"
		end

		def name
			return self.class.name.split('::').last
		end

		def permute!
			@optionParser.permute! if defined? @optionParser
		end

		def list_options
			puts @optionParser if defined? @optionParser
		end

	end

	if File.symlink?($0)
		@base_dir = File.dirname(File.readlink($0)) + "/platforms/"
	else
		@base_dir = File.dirname($0) + "/platforms/"
	end

	def self.get_platform platform_name
		#TODO: Read a list of available paths

		platform_package_path = @base_dir + platform_name + ".plat"
		unless Dir.exists? platform_package_path
			puts platform_package_path
			raise "The platform asked for (#{platform_name}) does not exist."
			#TODO : Output all searched for folders.
		end
		require platform_package_path + '/platform'

		unless Platforms.const_defined? platform_name
			raise "The #{platform_name} platform class has not been defined in the platform."
		end

		Platforms.const_get platform_name
	end

	def self.list_classes
		platforms = []
		#TODO: Read from list of available paths.
		#folder will be the block parameter.
		folder = @base_dir
		Dir.entries(folder).each do |d|
			next if d == '.' || d == '..'

			if File.directory? folder + d
				d = d[0..d.rindex(".")-1]

				platform = self.get_platform d
				if defined? platform.shortDesc
					platforms << "#{d} -- #{platform.shortDesc}"
				else
					platforms << d
				end
			else
				##TODO: Only on most verbose level of output...
				#$stderr.puts "In folder #{folder}, found #{d}, which is not a platform package."
			end


		end

		platforms
	end
end