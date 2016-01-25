require 'pp' # REMOVE THIS

module Platforms
	class IOS < Platform
		def initialize
			# Defaults
			@build_options = ArrayStruct.new(:configure_options => '--host=arm-apple-darwin')
			@build_options.arch     = []
			@build_options.sdk      = []
			@build_options.sdk_root = []
			$libbuildtool_params.compiler if $libbuildtool_params.compiler == nil

			@optionParser = OptionParser.new do |opts|
				opts.on('-a', '--arch', '=ARCHITECTURE', 'Architecture',
						"Default: none") do |arch|
					@build_options.arch = arch
					if arch and arch.match /arm.*/ then
						@build_options.configure_options = ""
					elsif arch and (arch.match(/x86.*/) or arch.match(/.*86/))
						@build_options.configure_options = ""
					elsif arch and arch.match /universal/
					else
						puts "Arch for iOS platform seems invalid : #{arch}"
						abort
					end
				end
				opts.on('--sdk', '=SDK', "SDK to use for compilation", "Can omit the .sdk suffix", "Use proper case!") do |opt_sdk|
					opt_sdk = opt_sdk.sub /\.sdk$/, ""
					@build_options.sdk = opt_sdk
				end

				opts.on('--list-sdks', "Lists SDKs") do
					puts "Listing SDKs found in XCode developer path."
					puts " -> Developer path: #{IOS.xcode_path}"
					puts ""
					IOS.list_SDKs.each do |name,list|
						puts "Available SDKs for platform '#{name}' :"
						list.each do |sdk|
							puts "  * #{sdk}"
						end
						puts ""
					end
					exit 0
				end

				opts.on('-h', '--help', 'Shows this help.') do
					puts opts
					puts "    "
					puts "    Because of the 'straightforward' design of libbuildtool, it is"
					puts "    currently not possible to loop inside libbuildtool to build"
					puts "    multiple targets."
					puts "    As a workaround, here's a set of bash commands that you can use:"
					puts "     libbuildtool --rebuild -p IOS -- --sdk=iPhoneSimulator8.1 --arch=x86_64 ;"
					puts "     for arch in x86_64 armv7 armv7s arm64 universal; do"
					puts "        libbuildtool --rebuild -p IOS -- --sdk=iPhoneOS8.1 --arch=$arch ;"
					puts "     done"
					puts "    As long as the semicolons are at the right place, it can be"
					puts "    used as a one-liner."
					puts "    Do not forget to supply the right SDK!"
					puts ""
					puts "    About the 'universal' -arch parameter"
					puts "    This platform has a special -arch=universal syntax where the"
					puts "    normal libbuildtool control will be hijacked and a custom"
					puts "    system will lipofy the static libraries that are currently"
					puts "    available in the different subfolders."
					exit
				end
			end

		end

		def permute!
			@optionParser.permute!

			# FIXME : Should instead be set in the main script by querying platform instance.
			$libbuildtool_params.install_dir = "#{Dir.pwd}/iOS/#{@build_options.arch.first}"

			# Hijacking the normal libbuildtool flow if universal.
			if @build_options.arch.first == "universal" then
				self.make_universal
				# If we happen to get here, it's not right as make_universal
				# should exit by itself.
				exit 1
			end

			plat = @build_options.sdk.first.sub(/([0-9]\.*)*$/, "")

			@build_options.sdk_root = File.join(
				IOS.xcode_path, "Platforms",
				"#{plat}.platform", "Developer", "SDKs",
				"#{@build_options.sdk}.sdk", 
			)

			# FIXME : Check those defaults...
			@build_options.CFLAGS << "-pipe -Wno-trigraphs -Wreturn-type -Wunused-variable"
			@build_options.CFLAGS << ([
				"-isysroot", @build_options.sdk_root,
				"-miphoneos-version-min=7.0",
				"-arch", @build_options.arch
			].join(" "))
			@build_options.CPPFLAGS = @build_options.CXXFLAGS = @build_options.CFLAGS

			@build_options.LDFLAGS << ([
				#"#{minversion}", # Used? Needed?
				"-isysroot", @build_options.sdk_root,
				"-arch", @build_options.arch
			].join(" "))

			@build_options.CC  = `#{[
				"xcrun",
				"-find",
				"-sdk", @build_options.sdk.first.downcase,
				"-find", "clang",
			].join(" ")}`.strip
			@build_options.CXX = @build_options.CC
			@build_options.AR  = `#{[
				"xcrun",
				"-find",
				"-sdk", @build_options.sdk.first.downcase,
				"-find", "ar",
			].join(" ")}`.strip

			if @build_options.arch.size > 0 then
				if @build_options.arch.first.match /arm.*/ then
					@build_options.configure_options = '--host=arm-apple-darwin'
				else
					@build_options.configure_options = '--host=x86_64'
				end
			end

		end

		# Validates the platform. Bails out by itself if invalid.
		def validate!
			unless @build_options.sdk.size > 0 then
				puts "No SDK set for build."
				exit 95
			end
			unless @build_options.sdk_root.size > 0 then
				puts "No SDK path set for build."
				exit 96
			end
			unless Dir.exists?(@build_options.sdk_root.first) then
				puts "SDK #{@build_options.sdk.first} could not be found."
				puts "Tried: #{@build_options.sdk_root}"
				exit 96
			end
			unless @build_options.arch.size > 0 then
				puts "No architecture set for build."
				exit 97
			end
		end

		def self.short_desc
			return 'This targets the iOS platforms (iPhone, iPod Touch, iPad)'
		end

		def self.list_SDKs
			sdks = {}
			["iPhoneOS", "iPhoneSimulator"].each do |plat|
				plat_sdk = Dir.entries(File.join(
					IOS.xcode_path, "Platforms",
					"#{plat}.platform", "Developer", "SDKs"
				))
				plat_sdk.select! do |sdk|
					# Skip . and ..
					if sdk.match /^\..*/ then
						false
					elsif sdk == "#{plat}.sdk"
						false
					else
						true
					end
				end
				sdks[plat] = plat_sdk
			end
			return sdks
		end

		def self.xcode_path
			`xcode-select -print-path`.strip
		end

		# Special function that hijacks the control flow of libbuildtool and
		# does needed stuff with lipo to make universal binaries.
		# This should be called after building all the needed architectures.
		def make_universal
			puts ":: Hijacking libbuildtool to make lipofied universal libraries."
			puts "   -> Discovering architectures built"
			
			install_dir = "#{Dir.pwd}/iOS"
			archs = Dir.entries(install_dir)
        
			archs.select! do |arch| not arch == "." and not arch == ".." and not arch == "universal" and File.directory?("#{install_dir}/#{arch}")  end
			archs.each do |arch|
				puts "      Discovered:  #{arch}"
			end
			puts "   -> Discovering libraries"
			libraries = []
			archs.each do |arch|
				libs = Dir.glob(File.join(install_dir, arch, "lib", "*.a"))
				libs.select! do |lib| not lib == "." and not lib == ".." end
				libs.map! do |lib| lib = File.basename(lib) end
				libraries.concat libs
			end
			libraries.uniq!
			libraries.sort!

			libraries.each do |arch|
				puts "      #{arch}"
			end

			FileUtils.mkdir_p File.join(install_dir, "universal", "lib")

			puts ":: Lipofying libraries"

			# This approach currently works, but might fail with symlinks...
			# Symlinks were handled in the old code, but, hum, I'm not doing
			# them right now as I have none to handle.
			libraries.each do |lib|
				final_lib = File.join(install_dir, "universal", "lib", lib)
				args = []
				archs.each do |arch|
					args << File.join(install_dir, arch, "lib", lib)
				end
				Exec.run("lipo", "-create", *args, "-output", final_lib)
			end

			puts ":: Copying header files."
			puts "..."
			# Header files copying currently assumes that built header files are the same.
			# We will copy those of the first arch.
			orig_dir = File.join(install_dir, archs.first, "include")
			inc_dir = File.join(install_dir, "universal", "include")
			FileUtils.rm_rf inc_dir
			FileUtils.cp_r orig_dir, inc_dir

			puts ""
			puts "All done!"
			exit 0
		end
	end
end
