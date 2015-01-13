# FIXME: It is almost certain that this will not work.
#
# This part is imported from the main libbuildtool script.
#### PATCH ###
#			Dir.chdir $global_state.current_dir
#			unless library.patcher
#				unless library.patch.nil?
#					if File.directory? library.patch then
#						library.patcher = Patch.copy
#					else
#						# library.patcher = Patch.copy
#					end
#				end
#			end
#
#			if library.patcher
#				scriptSuccess = library.patcher.call library, build_options
#				throw "Patch script failed for #{library.name}" if not scriptSuccess
#	        end
			
class Patcher < LBT::StepsFabricator
	class Copy
		def initialize patch_path
			@patch_path = patch_path
		end
		def run
			patch_dest = "#{@library.work_dir}"
			FileUtils.cp_r @patch_path, patch_dest

			true
		end
	end
end
