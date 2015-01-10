module Platforms
	class Android < Platform


		def initialize
			@build_options = ArrayStruct.new(:configure_options => '--host=arm-android-linux', :arch => 'arm')
			$options.install_dir = "#{Dir.pwd}/Android/#{@build_options.arch}"

			$options.compiler if $options.compiler == nil
			@optionParser = OptionParser.new do |opts|
				opts.on('-a', '--arch', '=ARCHITECTURE', 'Architecture', "Default: arm") do |arch|
					@build_options.arch = arch
					if arch == 'arm' then
						@build_options.configure_options = '--host=arm-android-linux'
					elsif arch == 'x86'
						@build_options.configure_options = '--host=x86-android-linux'
					end
					$options.install_dir = "#{Dir.pwd}/Android/#{@build_options.arch}"
				end
			end
		end

		def permute!
			@optionParser.permute!
		end



=begin
		def self.short_desc
			return 'Cygwin distribution of the Mingw compiler. Used to compile windows native trough Cygwin (Not for MSYS).'
		end
=end


	end

end
