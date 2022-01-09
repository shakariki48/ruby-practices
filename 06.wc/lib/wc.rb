#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  paths, options = parse_arguments
  puts wc(paths, options)
end

def wc(paths, options = %w[l w c])
  counts = []
  if paths.empty?
    file_content = $stdin.readlines.join
    counts << count('', file_content)
  else
    paths.each do |path|
      file_content = file_content(path)
      counts << count(path, file_content)
    end
  end
  counts << count_total(counts) if counts.size > 1
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
  opt.on('-w', 'The number of words in each input file is written to the standard output.') { options << 'w' }
  opt.on('-c', 'The number of bytes in each input file is written to the standard output.') { options << 'c' }
  paths = opt.parse(ARGV)
  options = %w[l w c] if options.empty?
  [paths, options]
end

def file_content(path)
  file_content = ''
  File.open(path) do |file|
    file_content = file.read
  end
  file_content
end

def count(path, file_content)
  {
    path: path,
    lines: file_content.lines.size,
    words: file_content.split(nil).size,
    bytes: file_content.bytesize
  }
end

def count_total(counts)
  {
    path: 'total',
    lines: counts.sum { |count| count[:lines] },
    words: counts.sum { |count| count[:words] },
    bytes: counts.sum { |count| count[:bytes] }
  }
end

def format_counts(counts, options = %w[l w c])
  lines = counts.map do |count|
    line = ''
    if options.include?('l')
      width = [max_char_length(counts, :lines), 7].max
      line += " #{count[:lines].to_s.rjust(width)}"
    end
    if options.include?('w')
      width = [max_char_length(counts, :words), 7].max
      line += " #{count[:words].to_s.rjust(width)}"
    end
    if options.include?('c')
      width = [max_char_length(counts, :bytes), 7].max
      line += " #{count[:bytes].to_s.rjust(width)}"
    end
    line += " #{count[:path]}"
    line.rstrip
  end
  lines.join("\n")
end

def max_char_length(counts, key)
  counts.map { |count| count[key].to_s.size }.max
end

main if __FILE__ == $PROGRAM_NAME
