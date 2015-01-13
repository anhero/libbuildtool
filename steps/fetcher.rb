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

			if Functions.program_exists 'curl'
				 Exec.run "curl", "-L", @url, "-o", "#{$global_state.source_dir}/#{@library.archive}"
				 return
			elsif Functions.program_exists 'wget'
				 Exec.run "wget", "--no-check-certificate", "-O", "#{$global_state.source_dir}/#{@library.archive} #{@url}", @url
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
end
