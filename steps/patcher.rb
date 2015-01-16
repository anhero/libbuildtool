# Steps generally used to patch software or libraries
class Steps::Patcher < LBT::StepsFabricator

	# Replaces files with other complete files.
	class Copy < LBT::Step
		# A new instance of Patcher::Copy
		# 
		# @param patch_path The path used as source for the copy operation.
		def initialize patch_path
			@patch_path = patch_path
		end
		# Runs the step
		#
		# @return [void]
		def run
			patch_dest = "#{@library.work_dir}"
			FileUtils.cp_r @patch_path, patch_dest

			true
		end
	end
end
