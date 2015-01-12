module Unpack
	def self.tar
		lambda do |library|
			Exec.run "tar", "-C", library.work_dir, "-xf", "#{$global_state.source_dir}/#{library.archive}"
		end
	end

	def self.zip
		lambda do |library|
			Exec.run "unzip", "-d", library.work_dir, "#{$global_state.source_dir}/#{library.archive}"
		end
	end
end
