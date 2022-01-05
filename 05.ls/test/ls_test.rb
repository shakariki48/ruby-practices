# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/ls'

class LsTest < Minitest::Test
  def test_parse_arguments
    # setup
    original_argv = ARGV.clone

    # './ls.rb' と実行した場合
    ARGV.clear.concat([])
    assert_equal(['.', []], parse_arguments)

    # './ls.rb ../lib' と実行した場合
    ARGV.clear.concat(['./lib'])
    assert_equal(['./lib', []], parse_arguments)

    # './ls.rb -a ..' と実行した場合
    ARGV.clear.concat(['-a', '..'])
    assert_equal(['..', ['a']], parse_arguments)

    # './ls.rb -r ..' と実行した場合
    ARGV.clear.concat(['-r', '..'])
    assert_equal(['..', ['r']], parse_arguments)

    # teardown
    ARGV.clear.concat(original_argv)
  end

  # === 05.ls/test ディレクトリで実行する ===
  def test_filenames
    assert_equal(['README.md', 'lib', 'test'], filenames('..'))

    assert_equal(['../lib/ls.rb'], filenames('../lib/ls.rb'))

    assert_equal(['/dev/null'], filenames('/dev/null'))

    assert_nil(filenames('dummy'))

    assert_equal([], filenames('empty_dir'))

    assert_equal(
      [
        '01.fizzbuzz', '02.calendar', '03.rake', '04.bowling', '05.ls',
        '06.wc', '07.bowling_object', '08.ls_object', '09.wc_object', 'README.md'
      ],
      filenames('../..')
    )
  end

  # === 05.ls/test ディレクトリで実行する ===
  def test_filenames_with_a_option
    options = ['a']

    assert_equal(
      ['.', '..', '.gitkeep', 'README.md', 'lib', 'test'],
      filenames('..', options: options)
    )

    assert_equal(['../lib/ls.rb'], filenames('../lib/ls.rb', options: options))

    assert_equal(['/dev/null'], filenames('/dev/null', options: options))

    assert_nil(filenames('dummy', options: options))

    assert_equal(
      [
        '.', '..', '.git', '.gitignore', '.rubocop.yml',
        '01.fizzbuzz', '02.calendar', '03.rake', '04.bowling', '05.ls',
        '06.wc', '07.bowling_object', '08.ls_object', '09.wc_object', 'README.md'
      ],
      filenames('../..', options: options)
    )
  end

  # === 05.ls/test ディレクトリで実行する ===
  def test_filenames_with_r_option
    options = ['r']

    assert_equal(['test', 'lib', 'README.md'], filenames('..', options: options))

    assert_equal(['../lib/ls.rb'], filenames('../lib/ls.rb', options: options))

    assert_equal(['/dev/null'], filenames('/dev/null', options: options))

    assert_nil(filenames('dummy', options: options))

    assert_equal(
      [
        'README.md', '09.wc_object', '08.ls_object', '07.bowling_object', '06.wc',
        '05.ls', '04.bowling', '03.rake', '02.calendar', '01.fizzbuzz'
      ],
      filenames('../..', options: options)
    )
  end

  def test_short_format
    # 1列の文字数は (最長のファイル名の長さ) + 1

    filenames = %w[lib test]
    expected = 'lib  test'
    assert_equal(expected, short_format(filenames))

    filenames = ['../lib/ls.rb']
    expected = '../lib/ls.rb'
    assert_equal(expected, short_format(filenames))

    filenames = [
      'Gemfile', 'Gemfile.lock', 'Procfile', 'README.md',
      'babel.config.js', 'bin', 'config', 'config.ru',
      'log', 'package.json', 'postcss.config.js'
    ]
    expected = <<~TEXT.chomp
      Gemfile           babel.config.js   log
      Gemfile.lock      bin               package.json
      Procfile          config            postcss.config.js
      README.md         config.ru
    TEXT
    assert_equal(expected, short_format(filenames))
  end
end

class LsTest < Minitest::Test
  def test_long_format
    path = './sample_files'
    filenames = %w[dir1 dir2 file1 file2 file3 link]
    expected = <<~TEXT.chomp
      total 12
      drwxr-xr-x 3 root root   96 Jan  2 04:34 dir1
      drwxr-xr-t 3 root root   96 Jan  2 04:34 dir2
      -rw-r--r-- 1 root root    6 Jan  2 05:03 file1
      -rwsr--r-- 1 root root    0 Jul  1  2021 file2
      -rw-r-Sr-- 1 root root 4097 Jan  2 05:02 file3
      lrwxr-xr-x 1 root root    5 Jan  2 04:35 link -> file1
    TEXT
    assert_equal(expected, long_format(path, filenames))

    # pathが空のディレクトリのときは合計サイズのみ
    path = './sample_files/dir1'
    filenames = []
    expected = 'total 0'
    assert_equal(expected, long_format(path, filenames))

    # pathがファイルのときは合計サイズはなし
    path = './sample_files/file1'
    filenames = %w[file1]
    expected = '-rw-r--r-- 1 root root 6 Jan  2 05:03 file1'
    assert_equal(expected, long_format(path, filenames))
  end

  def test_byte_size_or_dev_major_minor
    assert_equal('96', byte_size_or_dev_major_minor(File.new('./sample_files/dir1')))
    assert_equal('6', byte_size_or_dev_major_minor(File.new('./sample_files/file1')))
    assert_equal('1, 3', byte_size_or_dev_major_minor(File.new('/dev/null')))
  end
end

class LsTest < Minitest::Test
  def test_all
    # setup
    original_argv = ARGV.clone

    ARGV.clear.concat(['../..'])
    expected = <<~TEXT.chomp
      01.fizzbuzz       05.ls             09.wc_object
      02.calendar       06.wc             README.md
      03.rake           07.bowling_object
      04.bowling        08.ls_object
    TEXT
    path, options = parse_arguments
    filenames = filenames(path, options: options)
    actual = short_format(filenames)

    assert_equal(expected, actual)

    # teardown
    ARGV.clear.concat(original_argv)
  end

  def test_all_with_a_option
    # setup
    original_argv = ARGV.clone

    ARGV.clear.concat(['-a', '../..'])
    expected = <<~TEXT.chomp
      .                 01.fizzbuzz       06.wc
      ..                02.calendar       07.bowling_object
      .git              03.rake           08.ls_object
      .gitignore        04.bowling        09.wc_object
      .rubocop.yml      05.ls             README.md
    TEXT
    path, options = parse_arguments
    filenames = filenames(path, options: options)
    actual = short_format(filenames)

    assert_equal(expected, actual)

    # teardown
    ARGV.clear.concat(original_argv)
  end

  def test_all_with_r_option
    # setup
    original_argv = ARGV.clone

    ARGV.clear.concat(['-r', '../..'])
    expected = <<~TEXT.chomp
      README.md         06.wc             02.calendar
      09.wc_object      05.ls             01.fizzbuzz
      08.ls_object      04.bowling
      07.bowling_object 03.rake
    TEXT
    path, options = parse_arguments
    filenames = filenames(path, options: options)
    actual = short_format(filenames)

    assert_equal(expected, actual)

    # teardown
    ARGV.clear.concat(original_argv)
  end

  def test_all_with_l_option
    # setup
    original_argv = ARGV.clone

    ARGV.clear.concat(['-l', './sample_files'])
    expected = <<~TEXT.chomp
      total 12
      drwxr-xr-x 3 root root   96 Jan  2 04:34 dir1
      drwxr-xr-t 3 root root   96 Jan  2 04:34 dir2
      -rw-r--r-- 1 root root    6 Jan  2 05:03 file1
      -rwsr--r-- 1 root root    0 Jul  1  2021 file2
      -rw-r-Sr-- 1 root root 4097 Jan  2 05:02 file3
      lrwxr-xr-x 1 root root    5 Jan  2 04:35 link -> file1
    TEXT
    path, options = parse_arguments
    filenames = filenames(path, options: options)
    actual = long_format(path, filenames)

    assert_equal(expected, actual)

    # teardown
    ARGV.clear.concat(original_argv)
  end
end
