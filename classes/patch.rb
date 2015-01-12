module Patch
	def self.copy
		lambda do |library|
			patch_dest = "#{library.work_dir}"
			patch_path = library.patch
			FileUtils.cp_r patch_path, patch_dest
			true
		end
	end
end