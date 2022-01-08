# frozen_string_literal: true

# === 06.wc ディレクトリで実行する ===

require 'minitest/autorun'
require_relative '../lib/wc'

class WcTest < Minitest::Test
  def test_wc_single_file
    original_argv = ARGV.clone
    args = ['./test/sample_files/file1']
    ARGV.clear.concat(args)

    expected = <<-TEXT.chomp
      23     100    1183 ./test/sample_files/file1
    TEXT
    paths, options = parse_arguments
    actual = wc(paths, options)
    assert_equal(expected, actual)

    ARGV.clear.concat(original_argv)
  end

  def test_wc_single_file_with_l_option
    original_argv = ARGV.clone
    args = ['-l', 'test/sample_files/file1']
    ARGV.clear.concat(args)

    expected = <<-TEXT.chomp
      23 test/sample_files/file1
    TEXT
    paths, options = parse_arguments
    actual = wc(paths, options)
    assert_equal(expected, actual)

    ARGV.clear.concat(original_argv)
  end

  def test_wc_multi_files
    original_argv = ARGV.clone
    args = [
      'test/sample_files/file1',
      'test/sample_files/file2'
    ]
    ARGV.clear.concat(args)

    expected = <<-TEXT.chomp
      23     100    1183 test/sample_files/file1
       3      71     488 test/sample_files/file2
      26     171    1671 total
    TEXT
    paths, options = parse_arguments
    actual = wc(paths, options)
    assert_equal(expected, actual)

    ARGV.clear.concat(original_argv)
  end

  def test_wc_multi_files_with_l_option
    original_argv = ARGV.clone
    args = [
      '-l',
      './test/sample_files/file1',
      './test/sample_files/file2'
    ]
    ARGV.clear.concat(args)

    expected = <<-TEXT.chomp
      23 ./test/sample_files/file1
       3 ./test/sample_files/file2
      26 total
    TEXT
    paths, options = parse_arguments
    actual = wc(paths, options)
    assert_equal(expected, actual)

    ARGV.clear.concat(original_argv)
  end
end