# Steps used to unpack the software of library prior to building.
class Steps::Unpacker < LBT::StepsFabricator

	# Generic +Step+ that tries to unpack stuff automatically.
	#
	# It currently uses +library.archive+ as source file.
	#
	# It should handle tar files and zip files.
	#
	# The +Unpacker+ +Step+ will also auto-discover the sub-directory of
	# an archive and fill-in the +@library.build_subdir+ property with
	# that subdirectory. It will be used by +Builder+ +Step+s.
	#
	# If a common container is not unpacked by this class, *FILE A BUG*
	# or even better, add it, it might not be that hard (I hope).
	#
	class Auto < LBT::Step

		# A new instance of Unpacker::Auto
		def initialize options = {}
			@archive = options[:archive]
		end

		# Runs the step
		# @return [void]
		def run
			# When it's not passed to the constructor, it might be available
			# in the current library options.
			@archive = @library.archive unless @archive

			if not @archive.nil?
				Dir.chdir $global_state.project_dir

				FileUtils.mkdir_p $global_state.build_dir


				@library.work_dir = "#{$global_state.build_dir}/#{@library.name}"
				FileUtils.rm_rf @library.work_dir if Dir.exist? @library.work_dir
				FileUtils.mkdir_p @library.work_dir

				scriptSuccess = false
				if(@archive.include? '.tar' or @archive.include? 'tgz')
					scriptSuccess = untar "#{$global_state.source_dir}/#{@archive}", @library.work_dir
				elsif(@archive.include? '.zip')
					scriptSuccess = unzip "#{$global_state.source_dir}/#{@archive}", @library.work_dir
				elsif File.directory? "#{$global_state.source_dir}/#{@archive}"
					scriptSuccess = copy "#{$global_state.source_dir}/#{@archive}", @library.work_dir
				end

				throw "Unpack script failed for #{@library.name}" if not scriptSuccess

				# As documented, +@library.build_subdir+ is filled out here if it
				# wasn't previously set.
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
			# When it's not passed to the constructor, it might be available
			# in the current library options.
			@archive = @library.archive unless @archive

			if not @archive.nil?
				return true
			end
			return false
		end

		# Implementation of the untarring feature
		# @return [Boolean] true if succeeded.
		def untar src, out
			# Default tar tool
			tar = "tar"
			# Unless bsdtar exists
			tar = "bsdtar" if Exec.program_exists "bsdtar"

			Exec.run tar, *(@library.options.unpacker_options), "-C", out, "-xf", src
		end

		# Implementation of the unzipping feature
		# @return [Boolean] true if succeeded.
		def unzip src, out
			Exec.run "unzip", *(@library.options.unpacker_options), "-d", out, src
		end

		def copy src, out
			FileUtils.cp_r src, out
			true
		end
	end
end
