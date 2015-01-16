`libbuildtool`
==============

`libbuildtool` is a project-dependency builder. What it aims to do is to receive
instructions on how to build your dependencies and build them. This makes the
build process open and easily allow rebuild and reconfiguration of dependencies
by the project members. Furthermore, no binaries are needed in the repository,
making it slimmer and less encumbered.

    .__  ._____.  ___.         .__.__       .___ __                .__   
    |  | |__\_ |__\_ |__  __ __|__|  |    __| _//  |_  ____   ____ |  |  
    |  | |  || __ \| __ \|  |  \  |  |   / __ |\   __\/  _ \ /  _ \|  |  
    |  |_|  || \_\ \ \_\ \  |  /  |  |__/ /_/ | |  | (  <_> |  <_> )  |__
    |____/__||___  /___  /____/|__|____/\____ | |__|  \____/ \____/|____/
                 \/    \/                    \/                          

Installation
------------

`libbuildtool` is meant to be run as a standalone Ruby utility and is currently
not packaged nor integrated into the gem ecosystem.

The current installation method for `libbuildtool` consist mainly in cloning the
repository in a convenient location and either invoking `libbuildtool` by its full
path or using a shim script in your PATH to invoke it.

### Instructions

You could blindly follow those instructions, but I'd like you to think whether each
step is right for you and adapt them as you might need.

    # Make or use a folder for locally-installed software
    mkdir -p "$HOME/.opt/"
    # Go into that folder
    cd "$HOME/.opt/"
    # Clone the repository with a canonical name
    git clone https://github.com/anhero/libbuildtool.git libbuildtool
    # Verify the presence of the `libbuildtool` script
    ls -l "$HOME/.opt/libbuildtool/libbuildtool"

Once this is done,  you should be able to invoke `libbuildtool` with its full path.

    $HOME/.opt/libbuildtool/libbuildtool --help

If you want to be able to call it using only `libbuildtool` you could alias it
to your shell, or make a wrapper script that will call `libbuildtool` directly.

    # Assuming "$HOME/.bin/" is in your $PATH
    cd "$HOME/.bin"
    # Add a script
    cat <<'EOF' > libbuildtool
    #!/bin/sh
    exec "$HOME/.opt/libbuildtool/libbuildtool" "${@}"
    EOF
    # Make it executable
    chmod a+x libbuildtool
    # Verify it works
    libbuildtool --help

You should now be able to use `libbuildtool` directly.

Usage (user)
------------

*When you want to build the libraries of a project that uses `libbuildtool`.*

### Command-line usage (`libbuildtool --help`)

	Usage : libbuildtool [OPTION]
	Execute the build libraries listed by the given libraries list.

	Global options
		-h, --help                       Shows this help.
		-r, --rebuild                    Rebuild all the lib instead of building the remaining libs.
			--no-banner                  Do not output the ASCII art banner.
		-l, --libraries-list=FILENAME    Libraries list to use.
										 Default: libraries.rb
		-i, --install-dir=DIR            Final output directory.
										 Default: [...]
			--project-dir=DIR            Project directory.
										 Default: [...]
		-w, --work-dir=DIR               Temp work directory.
										 Default: [...]

	Platform options
		-P, --list-platforms             Prints a list of available platforms.
		-p, --platform=PLATFORM          Name of the platform file to use.
			--list-platform-options      Lists the options of the platform.

### Human-speak usage

A project that uses `libbuildtool` will generally have a folder for their 
libraries. This folder will have a main libraries file (defaulting to
`libraries.rb`) and a couple description files (special ruby files).

To build the libraries using `libbuildtool` you will have to go to that
sub-folder and call `libbuildtool`

	> cd $PROJECT
	> ls
	[...] libraries [...]
	> ls libraries/
	libraries.rb [...].rb
	> cd libraries
	> libbuildtool

This is the way you will generally use `libbuildtool`. The build instructions
of your project should have more informations about their particular uses of
`libbuildtool`. The project might define some more options for `libbuildtool`
and might have some more platforms configured, allowing cross-building to
other platforms.

Usage (developer)
-----------------

*When you want to integrate `libbuildtool` to your project.*

This is currently un-documented, but the API documentation should help. You
might want to take a look at one of the projects that are using `libbuildtool`
for inspiration.

The documentation API can be generated using [YARD](http://yardoc.org/). It
is not currently hosted anywhere, but we'll try to soon.

Projects using `libbuildtool`
------------------------------

  * https://github.com/anhero/BaconBox

Don't be shy, pull request your own!
