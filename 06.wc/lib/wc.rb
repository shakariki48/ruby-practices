#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def main
  paths, options, err_msg = parse_arguments
  puts err_msg.nil? ? wc(paths, options) : err_msg
end

def parse_arguments
  options = []
  opt = OptionParser.new
  usage_text = 'usage: wc [-lwc] [file ...]'
  opt.banner = <<~TEXT
    wc -- word, line, character, and byte count
    #{usage_text}
  TEXT
  opt.on('-l', 'The number of lines in each input file is written to the standard output.') { options << 'l' }
  opt.on('-w', 'The number of words in each input file is written to the standard output.') { options << 'w' }
  opt.on('-c', 'The number of bytes in each input file is written to the standard output.') { options << 'c' }
  paths = opt.parse(ARGV)
  options = %w[l w c] if options.empty?
  [paths, options, nil]
rescue OptionParser::InvalidOption => e
  specified_option = e.args[0].delete('-')
  err_msg = <<~TEXT
    wc: illegal option -- #{specified_option}
    #{usage_text}
  TEXT
  [nil, nil, err_msg]
end

def wc(paths, options = %w[l w c])
  counts = []
  if paths.empty?
    counts << count($stdin)
  else
    paths.each do |path|
      File.open(path) do |file|
        counts << count(file, path)
      end
    end
  end
  counts << count_total(counts) if counts.size > 1
  format_counts(counts, options)
end

def count(io, path = '')
  count = { lines: 0, words: 0, bytes: 0, path: path }
  io.each_line do |line|
    count[:lines] += 1
    count[:words] += line.split(nil).size
    count[:bytes] += line.bytesize
  end
  count
end

def count_total(counts)
  {
    lines: counts.sum { |count| count[:lines] },
    words: counts.sum { |count| count[:words] },
    bytes: counts.sum { |count| count[:bytes] },
    path: 'total'
  }
end

def format_counts(counts, options = %w[l w c])
  width = {
    lines: [max_char_length(counts, :lines), 7].max,
    words: [max_char_length(counts, :words), 7].max,
    bytes: [max_char_length(counts, :bytes), 7].max
  }
  lines = counts.map do |count|
    line = ''
    line += " #{count[:lines].to_s.rjust(width[:lines])}" if options.include?('l')
    line += " #{count[:words].to_s.rjust(width[:words])}" if options.include?('w')
    line += " #{count[:bytes].to_s.rjust(width[:bytes])}" if options.include?('c')
    line += " #{count[:path]}"
    line.rstrip
  end
  lines.join("\n")
end

def max_char_length(counts, key)
  counts.map { |count| count[key].to_s.size }.max
end

main if __FILE__ == $PROGRAM_NAME
