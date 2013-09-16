require 'net/http'
module Fetch
	def self.http
		lambda do |library|

			if Functions.execAvailable 'curl'
				return system("curl -L #{library.url} > #{library.archive}")
			elsif Functions.execAvailable 'wget'
				return system("wget -O #{library.archive} #{library.url}")
			else
				puts 'No tool available to fetch from http.'
				return false
			end
		end
	end
end