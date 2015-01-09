require 'net/http'
module Fetch
	def self.http
		lambda do |library|

			if Functions.execAvailable 'curl'
				return system("curl -L #{library.url} > #{$global_state.srcDir}/#{library.archive}")
			elsif Functions.execAvailable 'wget'
				return system("wget --no-check-certificate -O #{$global_state.srcDir}/#{library.archive} #{library.url}")
			else
				puts 'No tool available to fetch from http.'
				return false
			end
		end
	end

	def self.local
		lambda do |library|
			path = library.path || library.url

			dest = "#{$global_state.srcDir}/#{library.archive}"
			FileUtils.cp_r path, dest
			return true
		end
	end

end