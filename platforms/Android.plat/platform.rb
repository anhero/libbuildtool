require 'pp'
module Platforms
	class Android < Platform
		def initialize
			# Defaults
			@build_options = ArrayStruct.new(:configure_options => '--host=arm-android-linux')
			@build_options.arch = "arm"
			$libbuildtool_params.install_dir = "#{Dir.pwd}/Android/#{@build_options.arch.first}"
			$libbuildtool_params.compiler if $libbuildtool_params.compiler == nil
			@optionParser = OptionParser.new do |opts|
				opts.on('-a', '--arch', '=ARCHITECTURE', 'Architecture', "Default: arm") do |arch|
					@build_options.arch = arch
					if arch == 'arm' then
						@build_options.configure_options = '--host=arm-android-linux'
					elsif arch == 'x86'
						@build_options.configure_options = '--host=x86-android-linux'
					end
					$libbuildtool_params.install_dir = "#{Dir.pwd}/Android/#{@build_options.arch.first}"
				end
			end
		end

		def validate!
		end
		
		def permute!
			@optionParser.permute!
		end

	end

end
