mod_foobar
==========
Blank Joomla module - used as a template for quick module development.

You can install this module right away. Though this module comes with a very handy Ruby script to auto-generate a new module for you.

## 1. Script ##
### Features ###
* Auto change module name
* Auto change class name
* Auto change language constant
* Update author's information
* Support generating new language files
* Auto detect git version

### Usage ###

Run this in your favorite shell console

```
mod_foobar$ ./brand.rb
```

or

```
mod_foobar$ ruby brand.rb
```

## 2. Ruby Installation ##

Apparently, you need to have Ruby installed before using this script. Here is a quick overview on how to install Ruby in your operating system. For more information, please see [Download Ruby](https://www.ruby-lang.org/en/downloads/) page.
### On Windows ###
There’s a great project to help you install Ruby: [RubyInstaller](http://rubyinstaller.org/). It gives you everything you need to set up a full Ruby development environment on Windows. Just run it and you're set.

### On Linux ###
If your OS is Debian-based (e.g. Ubuntu and its derivatives...), you can use this command:

```
$ sudo apt-get install ruby
```

If your OS use pacman as the package manager:

```
$ sudo pacman -S ruby
```

Other package managers will have different syntaxes. You can search for how to install Ruby with your favorite distribution.

### On Mac ###
Many people on Mac OS X use Homebrew as a package manager. It’s really easy to get Ruby:


```
$ brew install ruby
```