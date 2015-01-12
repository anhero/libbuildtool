class Library
	attr_accessor :name, :hash, :license, :version,
	              :archive, :url, :path, :fetch,
	              :patch, :patcher, :unpack,
	              :build, :install, :prepare_build,
	              :build_subdir, :work_dir, :options

	def initialize
		self.fetch = false
		self.build = false
		self.prepare_build = false
		self.patcher = false
		self.unpack = false

	end

end
