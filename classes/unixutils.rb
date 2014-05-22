
module UnixUtils
	def mkdir_p path
		%x{mkdir -p #{path}}
	end

	def pwd
		%x{pwd}.rstrip
	end

	def rm_rf path
		%x{rm -rf #{path}}
	end

	def copy_file file, dest
		%x{cp #{file} #{dest}}
	end

	#copy multiple file keeping their file hierarchy
	def copy_files_tree files, dest
		files.each do |file|
			fileDest = "dest/#{file}"
			UnixUtils.mkdir_p File.dirname fileDest
			UnixUtils.copy_file header, fileDest
		end
	end

end