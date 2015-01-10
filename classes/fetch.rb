require 'net/http'
module Fetch
	def self.http
		lambda do |library|
			if Functions.execAvailable 'curl'
				return Exec.run "curl", "-L", library.url, "-o", library.archive
			elsif Functions.execAvailable 'wget'
				return Exec.run "wget", "--no-check-certificate", "-O", library.archive, library.url
			else
				puts 'No tool available to fetch from http.'
				return false
			end
		end
	end
end
