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

  def test_wc_single_file_with_w_option
    original_argv = ARGV.clone
    args = ['-w', 'test/sample_files/file1']
    ARGV.clear.concat(args)

    expected = <<-TEXT.chomp
     100 test/sample_files/file1
    TEXT
    paths, options = parse_arguments
    actual = wc(paths, options)
    assert_equal(expected, actual)

    ARGV.clear.concat(original_argv)
  end

  def test_wc_single_file_with_c_option
    original_argv = ARGV.clone
    args = ['-c', 'test/sample_files/file1']
    ARGV.clear.concat(args)

    expected = <<-TEXT.chomp
    1183 test/sample_files/file1
    TEXT
    paths, options = parse_arguments
    actual = wc(paths, options)
    assert_equal(expected, actual)

    ARGV.clear.concat(original_argv)
  end
end

class WcTest < Minitest::Test
  def test_wc_multi_files
    original_argv = ARGV.clone
    args = [
      'test/sample_files/file1',
      'test/sample_files/file2',
      'test/sample_files/file_ja'
    ]
    ARGV.clear.concat(args)

    expected = <<-TEXT.chomp
      23     100    1183 test/sample_files/file1
       3      71     488 test/sample_files/file2
       2      10     160 test/sample_files/file_ja
      28     181    1831 total
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
      './test/sample_files/file2',
      './test/sample_files/file_ja'
    ]
    ARGV.clear.concat(args)

    expected = <<-TEXT.chomp
      23 ./test/sample_files/file1
       3 ./test/sample_files/file2
       2 ./test/sample_files/file_ja
      28 total
    TEXT
    paths, options = parse_arguments
    actual = wc(paths, options)
    assert_equal(expected, actual)

    ARGV.clear.concat(original_argv)
  end

  def test_wc_multi_files_with_w_option
    original_argv = ARGV.clone
    args = [
      '-w',
      './test/sample_files/file1',
      './test/sample_files/file2',
      './test/sample_files/file_ja'
    ]
    ARGV.clear.concat(args)

    expected = <<-TEXT.chomp
     100 ./test/sample_files/file1
      71 ./test/sample_files/file2
      10 ./test/sample_files/file_ja
     181 total
    TEXT
    paths, options = parse_arguments
    actual = wc(paths, options)
    assert_equal(expected, actual)

    ARGV.clear.concat(original_argv)
  end

  def test_wc_multi_files_with_c_option
    original_argv = ARGV.clone
    args = [
      '-c',
      './test/sample_files/file1',
      './test/sample_files/file2',
      './test/sample_files/file_ja'
    ]
    ARGV.clear.concat(args)

    expected = <<-TEXT.chomp
    1183 ./test/sample_files/file1
     488 ./test/sample_files/file2
     160 ./test/sample_files/file_ja
    1831 total
    TEXT
    paths, options = parse_arguments
    actual = wc(paths, options)
    assert_equal(expected, actual)

    ARGV.clear.concat(original_argv)
  end
end

class WcTest < Minitest::Test
  def test_wc_stdin
    expected = `cat ./test/sample_files/file1 | wc`
    actual = `cat ./test/sample_files/file1 | ./lib/wc.rb`
    assert_equal(expected, actual)
  end
end
