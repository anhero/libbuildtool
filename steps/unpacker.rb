class Unpacker < LBT::StepsFabricator

	# The Unpacker::Auto might be the only class you will need
	# to unpack stuff.
	#
	# If a /common/ container is not unpacked by this class, FILE A BUG
	# or even better, add it, it might not be that hard (I hope).
	#
	class Auto < LBT::Step
		def initialize
		end

		def run

			Dir.chdir $global_state.project_dir

			FileUtils.mkdir_p $global_state.build_dir


			@library.work_dir = "#{$global_state.build_dir}/#{@library.name}"
			FileUtils.rm_rf @library.work_dir if Dir.exist? @library.work_dir
			FileUtils.mkdir_p @library.work_dir

			scriptSuccess = false
			if(@library.archive.include? '.tar' or @library.archive.include? 'tgz')
				scriptSuccess = untar
			elsif(@library.archive.include? '.zip')
				scriptSuccess = unzip
			end

			throw "Unpack script failed for #{@library.name}" if not scriptSuccess

			# TODO : Verify if there's not a better place to discover if a subdir is needed.
			if @library.build_subdir.nil?
				to_ignore = ["__MACOSX", ".", ".."]
				listing = Dir.entries @library.work_dir
				to_ignore.each do |ignored|
					listing.delete ignored
				end
				@library.build_subdir = (listing.first) if listing.length == 1
			end

		end

		def untar
			Exec.run "tar", "-C", @library.work_dir, "-xf", "#{$global_state.source_dir}/#{@library.archive}"
		end

		def unzip
			Exec.run "unzip", "-d", @library.work_dir, "#{$global_state.source_dir}/#{@library.archive}"
		end
	end
end
