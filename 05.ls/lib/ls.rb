#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

NUM_COLUMNS = 3

def main
  path, options = parse_arguments
  filenames = filenames(path, options: options)
  if filenames.nil?
    puts "ls: #{path}: No such file or directory"
  elsif !filenames.empty?
    puts format(filenames, NUM_COLUMNS)
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

def format(filenames, num_columns)
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

main if __FILE__ == $PROGRAM_NAME
