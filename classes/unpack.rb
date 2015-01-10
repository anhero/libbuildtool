module Unpack
	def self.tar
		lambda do |library, srcDir, destDir|
			Exec.run "tar", "-C", destDir, "-xf", "#{srcDir}/#{library.archive}"
		end
	end

	def self.zip
		lambda do |library, srcDir, destDir|
			Exec.run "unzip", "-d", destDir, "#{srcDir}/#{library.archive}"
		end
	end
end
