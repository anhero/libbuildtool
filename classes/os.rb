# Helper to discover platform specifics.
module OS

	# @return +true+ if running platform is Windows.
	def OS.windows?
		(/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
	end

	# @return +true+ if running platform is Mac OS X
	def OS.osx?
		(/darwin/ =~ RUBY_PLATFORM) != nil
	end

	# @return +true+ if a unix-like platform is used. (Assumes non-Windows)
	def OS.unix?
		!OS.windows?
	end

	# @return +true+ if platform is Linux. Wrongly assumes unix but not Mac OS X.
	def OS.linux?
		OS.unix? and not OS.osx?
	end
end
