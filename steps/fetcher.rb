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
		def initialize url, options = {}
			@url     = url
			@archive = options[:archive]
		end

		# Runs the step
		# @return [void]
		def run
			@archive = @library.archive unless @archive
			Dir.chdir $global_state.source_dir

			# Early-bailing to not download multiple times.
			puts "Checking for existence of file #{@archive}"
			if ::File.exist? @archive
				puts "Found, will not download."
				return true
			end
			puts "Not found, will download."
			puts " → #{@url}"

			if Exec.program_exists 'curl'
				return (Exec.run "curl", "-L", @url, "-o", "#{$global_state.source_dir}/#{@archive}" or raise "Could not download file.")
			elsif Exec.program_exists 'wget'
				return (Exec.run "wget", "--no-check-certificate", "-O", "#{$global_state.source_dir}/#{@archive} #{@url}", @url or raise "Could not download file.")
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
		def initialize path, options = {}
			@path     = path
			@archive  = options[:archive]
		end

		# Runs the step
		# @return [void]
		def run
			@archive = @library.archive unless @archive
			dest = "#{$global_state.source_dir}/#{@archive}"

			if ::File.exist? dest
				puts "Found, will not copy."
				return true
			end
			FileUtils.cp_r @path, dest
			return ::File.exist? dest
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
			return false if inst.nil?

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
