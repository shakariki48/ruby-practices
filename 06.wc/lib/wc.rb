#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

# $ wc [-l] [file ...]
# <lines> <words> <bytes> <file>
# ...
# [<lines_total> <words_total> <bytes_total> total]

def main
  paths, options = parse_arguments
  puts wc(paths, options)
end

def wc(paths, options)
  counts = []
  if paths.empty?
    file_content = gets
    counts << count('', file_content)
  else
    counts = paths.map do |path|
      file_content = file_content(path)
      counts << count(path, file_content)
    end
  end
  format_counts(counts, options)
end

def parse_arguments
  options = []
  opt = OptionParser.new
  opt.banner = <<~TEXT
    wc -- word, line, character, and byte count
    usage: wc [-l] [file ...]
  TEXT
  opt.on('-l', 'The number of lines in each input file is written to the standard output.') { options << 'l' }
  argv = opt.parse(ARGV)
  paths = argv || []
  [paths, options]
end

def file_content(path)
  ##
end

def count(path, file_content)
  ##
  # {
  #   path: ''
  #   lines: 0,
  #   words: 0,
  #   bytes: 0
  # }
end

def format_counts(counts, options = [])
  ##
end

main if __FILE__ == $PROGRAM_NAME
