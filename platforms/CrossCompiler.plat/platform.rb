# Notes:
#   About triples:
#   http://clang.llvm.org/docs/CrossCompilation.html#target-triple

module Platforms
	class CrossCompiler < Platform
		def initialize
			# Defaults
			@build_options = ArrayStruct.new()
			$libbuildtool_params.compiler if $libbuildtool_params.compiler == nil

			@optionParser = OptionParser.new do |opts|
				opts.on('--path', "=PATH", "Path to add to $PATH") do
					puts "--path is not implemented yet!"
					exit 1
				end

				opts.on('--arch', "=ARCH", "Architecture target of the cross-compiler.") do |opt_arch|
					@build_options.arch = opt_arch
				end
				opts.on('--system', "=SYSTEM", "System target of the cross-compiler.") do |opt_sys|
					@build_options.system = opt_sys
				end
				opts.on('--abi', "=ABI", "ABI target of the cross-compiler.") do |opt_abi|
					@build_options.abi = opt_abi
				end

				opts.on('--triple', "=TRIPLE", "Define arch-system-abi as a triple.") do |opt_triple|
					parts = opt_triple.split("-")
					@build_options.arch = parts.shift
					# Support vendor as arch-vendor-sys-abi
					# length 3 because we removed arch.
					@build_options.vendor = parts.shift if parts.length == 3
					@build_options.system = parts.shift
					@build_options.abi = parts.shift
				end

				opts.on('-h', '--help', 'Shows this help.') do
					puts opts
					puts "This is used for generic 'platform-less' cross-compiling."
					puts "An example would be compiling for windows in a Linux host"
					puts "using mingw. Another example would be cross-compiling for"
					puts "another architecture, like building from x86_64 for ARM."
					puts ""
					puts "About triples:"
					puts "For this platform, the term triple is used to identify a"
					puts "target platform. For more information, see the clang"
					puts "documentation here :"
					puts "http://clang.llvm.org/docs/CrossCompilation.html#target-triple" 
					puts ""
					puts "Using with cmake:"
					puts "You will most likely need a cmake build customized for the"
					puts "target. This is out of scope of this help, though."
					exit
				end
			end

		end

		def permute!
			@optionParser.permute!

			# FIXME : Should instead be set in the main script by querying platform instance.
			# FIXME ? : Folder structure has no concept of ABI. (important?)
			$libbuildtool_params.install_dir = "#{Dir.pwd}/#{@build_options.system.first}/#{@build_options.arch.first}"

			begin
				triple = ""
				triple << "#{@build_options.arch.first}-"
				triple << "#{@build_options.vendor.first}-" if @build_options.vendor.length > 0
				triple << "#{@build_options.system.first}-"
				triple << "#{@build_options.abi.first}"
				@build_options.triple = triple
			end

			@build_options.configure_options = "--host=#{@build_options.triple.first}"

			# FIXME : Check those defaults...
			@build_options.CFLAGS << "-pipe -Wno-trigraphs -Wreturn-type -Wunused-variable"
			@build_options.CFLAGS << ([
				#"-isysroot", @build_options.sdk_root,
				#"-miphoneos-version-min=7.0",
				#"-arch", @build_options.arch
			].join(" "))
			@build_options.CXXFLAGS = @build_options.CFLAGS

			@build_options.LDLAGS << ([
				#"-isysroot", @build_options.sdk_root,
				#"-arch", @build_options.arch
			].join(" "))

			@build_options.CC    = "#{@build_options.triple}-gcc"
			@build_options.CXX   = "#{@build_options.triple}-g++"
			@build_options.AR    = "#{@build_options.triple}-ar"
			@build_options.CMAKE = "#{@build_options.triple}-cmake" if Exec.program_exists "#{@build_options.triple}-cmake"
		end

		# Validates the platform. Bails out by itself if invalid.
		def validate!
			unless @build_options.arch
				puts "No --arch passed to CrossCompiler"
				exit 95
			end
			unless @build_options.system
				puts "No --system passed to CrossCompiler"
				exit 96
			end
			unless @build_options.abi
				puts "No --abi passed to CrossCompiler"
				exit 97
			end
		end

		def self.short_desc
			return 'Used for generic cross-compiling'
		end
	end
end
