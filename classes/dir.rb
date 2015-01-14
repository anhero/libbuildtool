# Extensions to the Ruby's +Dir+ class.
class Dir
	# This function goes into a subdirectory when only one subdirectory is available
	#
	# @return [Numeric] Value of +Dir.chdir()+ for the subdirectory if there is one.
	# @return [Boolean] false if no +chdir()+ occured.
	def self.gotoSubDir
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
