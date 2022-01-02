#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

def main
  path, options = parse_arguments
  filenames = filenames(path, options: options)
  if filenames.nil?
    puts "ls: #{path}: No such file or directory"
  elsif !filenames.empty?
    puts format(path, filenames, options: options)
  end
rescue OptionParser::InvalidOption => e
  specified_option = e.args[0].delete('-')
  message = <<~TEXT
    ls: invalid option -- '#{specified_option}'
    Try 'ls --help' for more information.
  TEXT
  puts message
end

def parse_arguments
  options = []
  opt = OptionParser.new
  opt.banner = 'Usage: ls [OPTION] [FILE]'
  opt.on('-a', 'do not ignore entries starting with .') { options << 'a' }
  opt.on('-l', 'use a long listing format') { options << 'l' }
  opt.on('-r', 'reverse order while sorting') { options << 'r' }
  argv = opt.parse(ARGV)
  path = argv[0] || '.'
  [path, options]
end

def filenames(path, options: [])
  return nil unless File.exist?(path)

  if File.directory?(path)
    flags = options.include?('a') ? File::FNM_DOTMATCH : 0
    filenames = Dir.glob('*', flags, base: path)
    options.include?('r') ? filenames.reverse : filenames
  else
    [path]
  end
end

def files(path, filenames)
  if File.directory?(path)
    file_paths = filenames.map { |filename| File.join(path, filename) }
    file_paths.map { |file_path| File.new(file_path) }
  else
    [File.new(path)]
  end
end

def format(path, filenames, options: [])
  if options.include?('l')
    long_format(path, filenames)
  else
    short_format(filenames)
  end
end

def short_format(filenames, num_columns = 3)
  max_filename_length = filenames.map(&:length).max
  num_rows = (filenames.length / num_columns.to_f).ceil
  filenames_matrix = []
  filenames.each_slice(num_rows) do |filenames_row|
    if filenames_row.length < num_rows
      blanks = Array.new(num_rows - filenames_row.length, '')
      filenames_row.push(*blanks)
    end
    filenames_matrix << filenames_row
  end
  lines = filenames_matrix.transpose.map do |filenames_row|
    line = filenames_row.map { |filename| filename.ljust(max_filename_length) }.join(' ')
    line.strip
  end
  lines.join("\n")
end

def long_format(path, filenames)
  files = files(path, filenames)
  lines = []
  if files.length > 1
    blocks_total = files.map { |file| blocks(file) }.sum
    lines << "total #{blocks_total}"
  end
  lines += files.map do |file|
    "#{type(file)}#{permission(file)} " \
    "#{num_hard_links(file).to_s.rjust(max_char_length(files, 'num_hard_links'))} " \
    "#{owner_name(file).ljust(max_char_length(files, 'owner_name'))} " \
    "#{group_name(file).ljust(max_char_length(files, 'group_name'))} " \
    "#{byte_size(file).to_s.rjust(max_char_length(files, 'byte_size'))} " \
    "#{timestamp_month(file)} " \
    "#{timestamp_day(file)} " \
    "#{timestamp_time_or_year(file).rjust(max_char_length(files, 'timestamp_time_or_year'))} " \
    "#{name(file)}"
  end
  lines.join("\n")
end

BLOCK_SIZE_STAT = 512
BLOCK_SIZE_LS = 1024 # GNU版lsコマンドのブロックサイズ (https://linuxjm.osdn.jp/info/GNU_coreutils/coreutils-ja_5.html)
def blocks(file)
  file.lstat.blocks * BLOCK_SIZE_STAT / BLOCK_SIZE_LS
end

def max_char_length(files, prop)
  files.map { |file| send(prop, file).to_s.length }.max
end

def mode(file)
  Kernel.format('%06o', file.lstat.mode) # 例. => '100755'
end

def type(file)
  types = {
    '01' => 'p',
    '02' => 'c',
    '04' => 'd',
    '06' => 'b',
    '10' => '-',
    '12' => 'l',
    '14' => 's'
  }
  octal_type = mode(file)[0, 2] # 例. => '10'
  types[octal_type]
end

def permission(file)
  permissions = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }
  octal_permissions = mode(file)[3, 3].split('') # 例. => '755'
  octal_permissions.map { |o| permissions[o] }.join('')
end

def num_hard_links(file)
  file.lstat.nlink
end

def owner_name(file)
  Etc.getpwuid(file.lstat.uid).name
end

def group_name(file)
  Etc.getgrgid(file.lstat.gid).name
end

def byte_size(file)
  file.lstat.size
end

def timestamp_month(file)
  mtime = file.lstat.mtime
  mtime.strftime('%b')
end

def timestamp_day(file)
  mtime = file.lstat.mtime
  mtime.strftime('%_d')
end

def timestamp_time_or_year(file)
  mtime = file.lstat.mtime
  mtime.strftime(mtime.year == Time.now.year ? '%H:%M' : '%Y')
end

def name(file)
  name = File.basename(file.path)
  name += " -> #{File.readlink(file.path)}" if type(file) == 'l'
  name
end

main if __FILE__ == $PROGRAM_NAME
