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

    # teardown
    ARGV.clear.concat(original_argv)
  end

  # === 05.ls/test ディレクトリで実行する ===
  def test_filenames
    assert_equal(
      %w[lib test],
      filenames('..')
    )
    assert_equal(
      ['../lib/ls.rb'],
      filenames('../lib/ls.rb')
    )
    assert_equal(
      [],
      filenames('dummy')
    )
  end

  # === 05.ls/test ディレクトリで実行する ===
  def test_filenames_with_dotfiles
    assert_equal(
      ['.', '..', '.gitkeep', 'lib', 'test'],
      filenames('..', includes_dotfiles: true)
    )
    assert_equal(
      ['../lib/ls.rb'],
      filenames('../lib/ls.rb', includes_dotfiles: true)
    )
    assert_equal(
      [],
      filenames('dummy', includes_dotfiles: true)
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
