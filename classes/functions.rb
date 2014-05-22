require 'digest'
require_relative 'dir'
module Functions
	def self.execAvailable name
		system("which #{name} &> /dev/null")
	end

	def self.gotoSubDir
		lambda do |library, options|
			return Dir.gotoSubDir()
		end
	end

	def self.checkFileHash hash, fileName
		hashGenerator = 'MD5'
		if hash.is_a? Array
			hashGenerator = hash[1]
			hash = hash[0]
		end
		hashGenerator = Digest.const_get hashGenerator
		return hashGenerator.file(fileName) == hash
	end
end
