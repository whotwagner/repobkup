#!/usr/bin/env ruby

require 'net/http'
require 'json'
require 'fileutils'

directory = "./"

def help
  warn "usage: #{$PROGRAM_NAME} <github-user> [ <dst-directory> ]"
  exit 1
end

# got this function from stackoverflow.com: 
#  stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end

gitbin = which("git")

if gitbin.nil?
  warn "git-binary not found"
  exit 1
end

if ARGV.length < 1 || ARGV.length > 2
  help
end

gituser = ARGV[0]
directory = ARGV[1] if ARGV.length == 2

unless File.directory?(directory)
	FileUtils::mkdir_p directory
end

uri = URI("https://api.github.com/users/#{gituser}/repos")

resp = Net::HTTP.get(uri)
parsed = JSON.parse(resp)

parsed.each do |p|
  if File.directory?("#{directory}/#{p['name']}")
    system("cd #{directory}/#{p['name']} && #{gitbin} pull")
  else
    system("#{gitbin} clone https://github.com/#{p['full_name']} #{directory}/#{p['name']}")
  end
end
