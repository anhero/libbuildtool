require 'digest'

# Classes used to validate and verify archives.
class Steps::Verifier < LBT::StepsFabricator

	# Checks using the md5 sum if the file is corrupted or not.
	#
	# Uses +library.archive+ as file to verify.
	class MD5 < LBT::Step
		# A new instance of Verifier::MD5
		#
		# @param hash The hash to verify against.
		def initialize hash, options = {}
			@hash    = hash
			@archive = options[:archive]
		end

		# Runs the step
		# @return [void]
		def run
			@archive = @library.archive unless @archive
			Dir.chdir $global_state.source_dir
			hashGenerator = Digest.const_get 'MD5'
			curr_hash = hashGenerator.file(@archive)
			valid = curr_hash == @hash
			if valid
				puts "File is valid"
			else
				puts "File is invalid"
				puts "Expected hash : #{@hash}, got #{curr_hash}"
			end
			return valid
		end
	end
end

