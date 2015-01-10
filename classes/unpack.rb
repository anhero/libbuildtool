module Unpack
	def self.tar
		lambda do |library, source_dir, destDir|
			Exec.run "tar", "-C", destDir, "-xf", "#{source_dir}/#{library.archive}"
		end
	end

	def self.zip
		lambda do |library, source_dir, destDir|
			Exec.run "unzip", "-d", destDir, "#{source_dir}/#{library.archive}"
		end
	end
end
