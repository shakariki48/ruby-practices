#!/usr/bin/env ruby
# frozen_string_literal: true

NUM_COLUMNS = 3

def main
  path = ARGV[0] || '.'
  filenames = filenames(path)
  if filenames.empty?
    puts "ls: #{path}: No such file or directory"
  else
    puts format(filenames, NUM_COLUMNS)
  end
end

def filenames(path)
  if File.file?(path)
    %W[#{path}]
  elsif File.directory?(path)
    Dir.glob('*', base: path).sort
  else
    []
  end
end

def format(filenames, num_columns)
  max_filename_length = filenames.map(&:length).max

  if filenames.length <= num_columns
    line = filenames.map { |filename| filename.ljust(max_filename_length) }.join(' ')
    return line.strip
  end

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
