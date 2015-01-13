class Verifier < LBT::StepsFabricator
	class MD5 < LBT::Step
		def initialize hash
			@hash    = hash
		end
		def run
			Dir.chdir $global_state.source_dir
			hashGenerator = Digest.const_get 'MD5'
			valid = hashGenerator.file(@library.archive) == @hash
			if valid
				puts "File is valid"
			else
				puts "File is invalid"
			end
			return valid
		end
	end
end

