class Dir
	# This is an ugly function
	# TODO: Fix to properly handle strings and hashes
	# Man... String does have include?... though it wouldn't work properly...
	# Furthermore, hashes' include? works with keys.
	def self.globmask(glob, excludeMasks)
		#I'm a noob. Don't know if there's another better way to deal with this...
		unless excludeMasks.respond_to? "include?"
			raise "The excludeMasks should respond to include?."
		end
		Dir.glob(glob).select do |file|
			! file.split("/").any? {|part| excludeMasks.include? part}
		end
	end


	def self.gotoSubDir
		listing = Dir.entries '.'
		count = 4
		count -=1 if not listing.include? '"__MACOSX"'
		return (Dir.chdir(listing[count -1]) == 0) if listing.length == count
		return false
	end
end