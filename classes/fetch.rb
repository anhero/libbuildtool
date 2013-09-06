require 'net/http'
class Fetch
	def self.http
		lambda do |library|

			if Functions.execAvailable 'curl'
				return system("curl -L #{library.url} > #{library.archive}")
			else
				puts 'No tool available to fetch from http.'
				return false
			end
		end
	end
end