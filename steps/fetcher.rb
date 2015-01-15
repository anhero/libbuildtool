# encoding: UTF-8
require 'net/http'

# Steps generally used to get the software or library.
class Steps::Fetcher < LBT::StepsFabricator

	# Fetches an HTTP ressource.
	#
	# The URL used is the one passed to its constructor.
	#
	# Uses +library.archive+ as the output filename.
	#
	class HTTP < LBT::Step
		# A new instance of Fetcher::HTTP
		# 
		# @param url URL to the ressource.
		def initialize url
			# TODO : Accept a filename as second parameter to generalize class.
			@url     = url
		end

		# Runs the step
		# @return [void]
		def run
			Dir.chdir $global_state.source_dir

			# Early-bailing to not download multiple times.
			puts "Checking for existence of file #{@library.archive}"
			if ::File.exist? @library.archive
				puts "Found, will not download."
				return
			end
			puts "Not found, will download."
			puts " → #{@url}"

			if Functions.program_exists 'curl'
				 Exec.run "curl", "-L", @url, "-o", "#{$global_state.source_dir}/#{@library.archive}" or raise "Could not download file."
				 return
			elsif Functions.program_exists 'wget'
				 Exec.run "wget", "--no-check-certificate", "-O", "#{$global_state.source_dir}/#{@library.archive} #{@url}", @url or raise "Could not download file."
				 return
			else
				raise 'No tool available to fetch from http.'
			end
		end
	end

	# Copies a file or tree.
	#
	# The path used is the path passed to its constructor.
	#
	# Uses +library.archive+ as the destination.
	#
	class Copy < LBT::Step
		# A new instance of Fetcher::Copy
		# 
		# @param path The path used as source for the copy operation.
		def initialize path
			# TODO : Accept a destination as second parameter to generalize class.
			@path     = path
		end

		# Runs the step
		# @return [void]
		def run
			if ::File.exist? @library.archive
				puts "Found, will not copy."
				return
			end
			dest = "#{$global_state.source_dir}/#{@library.archive}"
			FileUtils.cp_r @path, dest
		end
	end

	# This +Fetcher+ automatically calls the right +Fetcher+ depending on what the
	# the +Library+ defines.
	#
	# Uses either
	# * +library.url+
	# * +library.path*
	#
	# It prefers +library.url+
	#
	# It is used as an opinionated default to +Library+.
	class Auto < LBT::Step
		# Runs the step
		# @return [void]
		def run
			inst = nil
			if not @library.url.nil?
				inst = HTTP.new @library.url
			elsif not @library.path.nil?
				inst = Copy.new @library.path
			end
			return if inst.nil?

			inst.set_owner @library
			inst.run
		end

		# Will not run if it cannot find a path or url to fetch
		# @return [Boolean] true if it will run.
		def should_run
			unless @library.path.nil? and @library.url.nil?
				return true
			end
			return false
		end
	end
end
