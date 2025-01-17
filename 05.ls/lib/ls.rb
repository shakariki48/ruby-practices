#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'date'

def main
  path, options = parse_arguments
  filenames = filenames(path, options: options)
  if filenames.nil?
    puts "ls: cannot access '#{path}': No such file or directory"
  elsif options.include?('l')
    puts long_format(path, filenames)
  elsif !filenames.empty?
    puts short_format(filenames)
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
    filenames.map do |filename|
      file_path = File.join(path, filename)
      File.new(file_path)
    end
  else
    [File.new(path)]
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
  if File.directory?(path)
    blocks_total = files.map { |file| blocks(file) }.sum
    lines << "total #{blocks_total}"
  end
  lines += files.map do |file|
    "#{type(file)}#{permission(file)} " \
    "#{num_hard_links(file).to_s.rjust(max_char_length(files, 'num_hard_links'))} " \
    "#{owner_name(file).ljust(max_char_length(files, 'owner_name'))} " \
    "#{group_name(file).ljust(max_char_length(files, 'group_name'))} " \
    "#{byte_size_or_dev_major_minor(file).rjust(max_char_length(files, 'byte_size_or_dev_major_minor'))} " \
    "#{timestamp_month(file)} " \
    "#{timestamp_day(file)} " \
    "#{timestamp_time_or_year(file).rjust(max_char_length(files, 'timestamp_time_or_year'))} " \
    "#{filename(path, file)}"
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
  format('%06o', file.lstat.mode) # 例. => '100755'
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
  types[mode(file)[0..1]]
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
  user_permission = permissions[mode(file)[3]]
  group_permission = permissions[mode(file)[4]]
  others_permission = permissions[mode(file)[5]]
  case mode(file)[2]
  when '4' then user_permission = user_permission[0..1] + (user_permission[2] == 'x' ? 's' : 'S')
  when '2' then group_permission = group_permission[0..1] + (group_permission[2] == 'x' ? 's' : 'S')
  when '1' then others_permission = others_permission[0..1] + (others_permission[2] == 'x' ? 't' : 'T')
  end
  "#{user_permission}#{group_permission}#{others_permission}"
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

def byte_size_or_dev_major_minor(file)
  if file.lstat.blockdev? || file.lstat.chardev?
    "#{file.lstat.rdev_major}, #{file.lstat.rdev_minor}"
  else
    file.lstat.size.to_s
  end
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
  # 最終更新時刻が6ヶ月以上前（または未来の日付）なら年を返し、そうでなければ時間を返す
  # https://www.gnu.org/software/coreutils/manual/coreutils.html#Formatting-file-timestamps
  mtime = file.lstat.mtime
  six_months_ago = Date.today.prev_month(6).to_time
  mtime.strftime(mtime < six_months_ago || mtime > Time.now ? '%Y' : '%H:%M')
end

def filename(path, file)
  filename = File.directory?(path) ? File.basename(file.path) : path
  filename += " -> #{File.readlink(file.path)}" if file.lstat.symlink?
  filename
end

main if __FILE__ == $PROGRAM_NAME
