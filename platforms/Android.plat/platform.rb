module Platforms
	class Android < Platform


		def initialize
			@buildOptions = ArrayStruct.new(:configureOptions => '--host=arm-android-linux', :arch => 'arm')
			$options.install_dir = "#{Dir.pwd}/Android/#{@buildOptions.arch}"

			$options.compiler if $options.compiler == nil
			@optionParser = OptionParser.new do |opts|
				opts.on('-a', '--arch', '=ARCHITECTURE', 'Architecture', "Default: arm") do |arch|
					@buildOptions.arch = arch
					if arch == 'arm' then
						@buildOptions.configureOptions = '--host=arm-android-linux'
					elsif arch == 'x86'
						@buildOptions.configureOptions = '--host=x86-android-linux'
					end
					$options.install_dir = "#{Dir.pwd}/Android/#{@buildOptions.arch}"
				end
			end
		end

		def permute!
			@optionParser.permute!
		end



=begin
		def self.shortDesc
			return 'Cygwin distribution of the Mingw compiler. Used to compile windows native trough Cygwin (Not for MSYS).'
		end
=end


	end

end
