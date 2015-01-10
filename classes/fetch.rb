require 'net/http'
module Fetch
	def self.http
		lambda do |library|
			if Functions.program_exists 'curl'
				return Exec.run "curl", "-L", library.url, "-o", "#{$global_state.source_dir}/#{library.archive}"
			elsif Functions.program_exists 'wget'
				return Exec.run "wget", "--no-check-certificate", "-O", "#{$global_state.source_dir}/#{library.archive} #{library.url}", library.url
			else
				puts 'No tool available to fetch from http.'
				return false
			end
		end
	end

	def self.local
		lambda do |library|
			path = library.path || library.url

			dest = "#{$global_state.source_dir}/#{library.archive}"
			FileUtils.cp_r path, dest
			return true
		end
	end
end
