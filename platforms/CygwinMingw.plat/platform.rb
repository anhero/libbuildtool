module Platforms
	class CygwinMingw < Platform


		def initialize
			@buildOptions = OpenStruct.new(:CC => 'i686-pc-mingw32-gcc', :CXX => 'i686-pc-mingw32-g++', :WINDRES => 'i686-pc-mingw32-windres')


			$options.compiler if $options.compiler == nil
			@optionParser = OptionParser.new do |opts|
				#defaultOptions opts
			end
		end




		def self.shortDesc
			return 'Cygwin distribution of the Mingw compiler. Used to compile windows native trough Cygwin (Not for MSYS).'
		end


	end

end