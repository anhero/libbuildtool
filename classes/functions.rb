require 'digest'
require_relative 'dir'
module Functions
	def self.program_exists name
		Exec.run "which", name, :silent=>true
	end

	def self.gotoSubDir
		lambda do |library, options|
			return Dir.gotoSubDir()
		end
	end
end
