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
    Dir.open(path).each_child.to_a
  else
    []
  end
end

def format(filenames, num_columns)
  # TODO: 実装する
end

main if __FILE__ == $PROGRAM_NAME
