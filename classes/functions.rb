require 'digest'
module Functions
	def self.execAvailable name
		system("which #{name} &> /dev/null")
	end

	def self.gotoSubDir
		lambda do |library|
			listing = Dir.entries '.'
			count = 4
			count -=1 if not listing.include? '"__MACOSX"'
			return (Dir.chdir(listing[count -1]) == 0) if listing.length == count
			return false
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
