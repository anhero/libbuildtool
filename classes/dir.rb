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
		# This dirty function goes into a subdirectory when
		# only one subdirectory is available.
		#
		# Those folders are to be ignored.
		to_ignore = ["__MACOSX", ".", ".."]
		listing = Dir.entries '.'
		to_ignore.each do |ignored|
			listing.delete ignored
		end
		# If there's only one component in the directory, go into it.
		return Dir.chdir(listing.first) if listing.length == 1
		return false
	end
end
