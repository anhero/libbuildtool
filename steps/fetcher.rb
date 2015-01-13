require 'net/http'

class Steps::Fetcher < LBT::StepsFabricator
	class HTTP < LBT::Step
		def initialize url
			@url     = url
		end
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

	class Copy < LBT::Step
		def initialize path
			@path     = path
		end
		def run
			dest = "#{$global_state.source_dir}/#{@library.archive}"
			FileUtils.cp_r @path, dest
		end
	end

	# This +Fetcher+ automatically calls the right +Fetcher+ depending on what the
	# the +Library+ defines.
	class Auto < LBT::Step
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

		# When no step is automatically run, it should not be run.
		def should_run
			unless @library.path.nil? and @library.url.nil?
				return true
			end
			return false
		end
	end
end
