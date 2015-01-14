# Steps used to unpack the software of library prior to building.
class Steps::Unpacker < LBT::StepsFabricator

	# Generic +Step+ that tries to unpack stuff automatically.
	#
	# It currently uses +library.archive+ as source file.
	#
	# It should handle tar files and zip files.
	#
	# If a common container is not unpacked by this class, *FILE A BUG*
	# or even better, add it, it might not be that hard (I hope).
	#
	class Auto < LBT::Step

		# A new instance of Unpacker::Auto
		def initialize
			# TODO : Accept filename as input and use instead of library.archive.
			#        If no filename passed, use library.archive...
		end

		# Runs the step
		# @return [void]
		def run
			if not @library.archive.nil?  and not File.exist? @library.archive
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
		end

		# Hides the step when no archive needs to be unpacked
		# @return [Boolean] true if it will run.
		def should_run
			if not @library.archive.nil?  and not File.exist? @library.archive
				return true
			end
			return false
		end

		# Implementation of the untarring feature
		# @return [Boolean] true if succeeded.
		def untar
			# FIXME: Generalization by passing filename and outputdir
			Exec.run "tar", "-C", @library.work_dir, "-xf", "#{$global_state.source_dir}/#{@library.archive}"
		end

		# Implementation of the unzipping feature
		# @return [Boolean] true if succeeded.
		def unzip
			# FIXME: Generalization by passing filename and outputdir
			Exec.run "unzip", "-d", @library.work_dir, "#{$global_state.source_dir}/#{@library.archive}"
		end
	end
end
