#!/usr/bin/env ruby
# frozen_string_literal: true

NUM_COLUMNS = 3

def main
  path = ARGV[0] || '.'
  filenames = get_filenames(path)
  if filenames.empty?
    puts "ls: #{path}: No such file or directory"
  else
    puts format(filenames, NUM_COLUMNS)
  end
end

def get_filenames(path)
  if File.file?(path)
    %W[#{path}]
  elsif File.directory?(path)
    files = Dir.open(path).each_child.sort
    files.reject { |f| f.start_with?('.') }
  else
    []
  end
end

def format(filenames, num_columns)
  max_filename_length = filenames.map(&:length).max

  if filenames.length <= num_columns
    line = filenames.map { |f| f.ljust(max_filename_length) }.join(' ')
    return line.strip
  end

  num_rows = (filenames.length / num_columns.to_f).ceil
  matrix = []
  filenames.each_slice(num_rows) do |f|
    if f.length < num_rows
      blanks = Array.new(num_rows - f.length, '')
      f.push(*blanks)
    end
    matrix << f
  end
  lines = matrix.transpose.map do |f|
    line = f.map { |filename| filename.ljust(max_filename_length) }.join(' ')
    line.strip
  end
  lines.join("\n")
end

main if __FILE__ == $PROGRAM_NAME
