require "rubygems"
require "pp"
require "colorize"

if ARGV.count == 0
  puts "ERROR: Please provide a directory to scan for git repositories"
  Kernel.exit
end

DIR=ARGV[0]
systemuser = `whoami`.gsub("\n","")
SINCE=ARGV.count > 1 ? ARGV[1] : "8 days ago"
USER=systemuser[0].upcase + systemuser[1..-1]
GROUP_BY_DAY=true

def process(user, since, dir)
  data=`cd #{dir}; git log --all --full-history --pretty=format:"%ai|%s" --author="#{user}" --since="#{since}"`
  parsed_data=data.split("\n").sort.reverse.map{|x| x.split("|")}
  
  if parsed_data.count == 0
    return
  end
  
  project_name = dir.split("/").last
  puts "#{project_name.bold.light_magenta}: "
  if GROUP_BY_DAY
    parsed_data.group_by{|date, msg| date.split(" ").first}.each do |date, commits|
      puts "#{date.to_s.light_black}"
      commits.each do |date, message|
        puts "  #{message}"
      end
    end
  else
    parsed_data.each do |date, message|
      puts "  #{date.to_s.light_black} #{message}"
    end
  end
end

dirs = Dir.glob(File.expand_path(DIR) + "/*/.git")
puts "Scanning #{dirs.count} directories".green
dirs.each do |workingdir|
  process(USER, SINCE, workingdir.gsub(".git", ""))
end
