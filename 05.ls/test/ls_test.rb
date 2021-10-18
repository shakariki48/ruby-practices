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
    assert_equal(%w[lib test], filenames('..'))

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
      ['.', '..', '.gitkeep', 'lib', 'test'],
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

    assert_equal(%w[test lib], filenames('..', options: options))

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

  def test_format
    num_columns = 3

    # 1列の文字数は (最長のファイル名の長さ) + 1

    filenames = %w[lib test]
    expected = 'lib  test'
    assert_equal(expected, format(filenames, num_columns))

    filenames = ['../lib/ls.rb']
    expected = '../lib/ls.rb'
    assert_equal(expected, format(filenames, num_columns))

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
    assert_equal(expected, format(filenames, num_columns))
  end
end

class LsTest < Minitest::Test
  def test_all
    # setup
    original_argv = ARGV.clone

    ARGV.clear.concat(['../..'])
    num_columns = 3
    expected = <<~TEXT.chomp
      01.fizzbuzz       05.ls             09.wc_object
      02.calendar       06.wc             README.md
      03.rake           07.bowling_object
      04.bowling        08.ls_object
    TEXT
    path, options = parse_arguments
    filenames = filenames(path, options: options)
    actual = format(filenames, num_columns)

    assert_equal(actual, expected)

    # teardown
    ARGV.clear.concat(original_argv)
  end

  def test_all_with_a_option
    # setup
    original_argv = ARGV.clone

    ARGV.clear.concat(['-a', '../..'])
    num_columns = 3
    expected = <<~TEXT.chomp
      .                 01.fizzbuzz       06.wc
      ..                02.calendar       07.bowling_object
      .git              03.rake           08.ls_object
      .gitignore        04.bowling        09.wc_object
      .rubocop.yml      05.ls             README.md
    TEXT
    path, options = parse_arguments
    filenames = filenames(path, options: options)
    actual = format(filenames, num_columns)

    assert_equal(actual, expected)

    # teardown
    ARGV.clear.concat(original_argv)
  end

  def test_all_with_r_option
    # setup
    original_argv = ARGV.clone

    ARGV.clear.concat(['-r', '../..'])
    num_columns = 3
    expected = <<~TEXT.chomp
      README.md         06.wc             02.calendar
      09.wc_object      05.ls             01.fizzbuzz
      08.ls_object      04.bowling
      07.bowling_object 03.rake
    TEXT
    path, options = parse_arguments
    filenames = filenames(path, options: options)
    actual = format(filenames, num_columns)

    assert_equal(actual, expected)

    # teardown
    ARGV.clear.concat(original_argv)
  end
end
