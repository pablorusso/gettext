# encoding: utf-8
#
# Copyright (C) 2012  Haruka Yoshihara <yoshihara@clear-code.com>
# Copyright (C) 2012  Kouhei Sutou <kou@clear-code.com>
# Copyright (C) 2010  masone (Christian Felder) <ema@rh-productions.ch>
# Copyright (C) 2009  Vladimir Dobriakov <vladimir@geekq.net>
# Copyright (C) 2009-2010  Masao Mutoh
#
# License: Ruby's or LGPL
#
# This library is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'gettext/tools/parser/ruby'
require 'gettext/tools/parser/glade'
require 'gettext/tools/parser/erb'

require 'gettext/tools/rgettext'

class TestGetTextParser < Test::Unit::TestCase
  def setup
    @rgettext = GetText::RGetText.new
  end

  def test_ruby
    @ary = @rgettext.parse(['fixtures/_.rb'])

    assert_target 'aaa', ['fixtures/_.rb:10']
    assert_target 'aaa\n', ['fixtures/_.rb:14']
    assert_target 'bbb\nccc', ['fixtures/_.rb:18']
    assert_target 'bbb\nccc\nddd\n', ['fixtures/_.rb:22']
    assert_target 'eee', ['fixtures/_.rb:29', 'fixtures/_.rb:33']
    assert_target 'fff', ['fixtures/_.rb:33']
    assert_target 'ggghhhiii', ['fixtures/_.rb:37']
    assert_target 'a"b"c"', ['fixtures/_.rb:43']
    assert_target 'd"e"f"', ['fixtures/_.rb:47']
    assert_target 'jjj', ['fixtures/_.rb:51']
    assert_target 'kkk', ['fixtures/_.rb:52']
    assert_target 'lllmmm', ['fixtures/_.rb:56']
    assert_target 'nnn\nooo', ['fixtures/_.rb:64']
    assert_target "\#", ['fixtures/_.rb:68', 'fixtures/_.rb:72']
    assert_target "\\taaa", ['fixtures/_.rb:76']
    assert_target "Here document1\\nHere document2\\n", ['fixtures/_.rb:80']
    assert_target "Francois Pinard", ['fixtures/_.rb:99'] do |t|
      assert_match /proper name/, t.comment
      assert_match /Pronunciation/, t.comment
    end

    assert_target("No TRANSLATORS comment", ["fixtures/_.rb:102"]) do |t|
      assert_nil(t.comment)
    end

    assert_target "self explaining", ['fixtures/_.rb:107'] do |t|
      assert_nil t.comment
    end

    assert_target "This is a # including string.", ["fixtures/_.rb:111"]

    # TODO: assert_target "in_quote", ['fixtures/_.rb:98']
  end

  def test_ruby_N
    @ary = @rgettext.parse(['fixtures/N_.rb'])

    assert_target 'aaa', ['fixtures/N_.rb:10']
    assert_target 'aaa\n', ['fixtures/N_.rb:14']
    assert_target 'bbb\nccc', ['fixtures/N_.rb:18']
    assert_target 'bbb\nccc\nddd\n', ['fixtures/N_.rb:22']
    assert_target 'eee', ['fixtures/N_.rb:29', 'fixtures/N_.rb:33']
    assert_target 'fff', ['fixtures/N_.rb:33']
    assert_target 'ggghhhiii', ['fixtures/N_.rb:37']
    assert_target 'a"b"c"', ['fixtures/N_.rb:43']
    assert_target 'd"e"f"', ['fixtures/N_.rb:47']
    assert_target 'jjj', ['fixtures/N_.rb:51']
    assert_target 'kkk', ['fixtures/N_.rb:52']
    assert_target 'lllmmm', ['fixtures/N_.rb:56']
    assert_target 'nnn\nooo', ['fixtures/N_.rb:64']
  end

  def test_ruby_n
    @ary = @rgettext.parse(['fixtures/ngettext.rb'])
    assert_plural_target "aaa", "aaa2", ['fixtures/ngettext.rb:10']
    assert_plural_target "bbb\\n", "ccc2\\nccc2", ['fixtures/ngettext.rb:14']
    assert_plural_target "ddd\\nddd", "ddd2\\nddd2", ['fixtures/ngettext.rb:18']
    assert_plural_target "eee\\neee\\n", "eee2\\neee2\\n", ['fixtures/ngettext.rb:23']
    assert_plural_target "ddd\\neee\\n", "ddd\\neee2", ['fixtures/ngettext.rb:29']
    assert_plural_target "fff", "fff2", ['fixtures/ngettext.rb:36', 'fixtures/ngettext.rb:40']
    assert_plural_target "ggg", "ggg2", ['fixtures/ngettext.rb:40']
    assert_plural_target "ggghhhiii", "jjjkkklll", ['fixtures/ngettext.rb:44']
    assert_plural_target "a\"b\"c\"", "a\"b\"c\"2", ['fixtures/ngettext.rb:53']
    assert_plural_target "mmmmmm", "mmm2mmm2", ['fixtures/ngettext.rb:61']
    assert_plural_target "nnn", "nnn2", ['fixtures/ngettext.rb:62']
    assert_plural_target "comment", "comments", ['fixtures/ngettext.rb:78'] do |t|
      assert_equal "please provide translations for all\n the plural forms!", t.comment
    end
  end

  def test_ruby_p
    @ary = @rgettext.parse(['fixtures/pgettext.rb'])
    assert_target_in_context "AAA", "BBB", ["fixtures/pgettext.rb:10", "fixtures/pgettext.rb:14"]
    assert_target_in_context "AAA|BBB", "CCC", ["fixtures/pgettext.rb:18"]
    assert_target_in_context "AAA", "CCC", ["fixtures/pgettext.rb:22"]
    assert_target_in_context "CCC", "BBB", ["fixtures/pgettext.rb:26"]
    assert_target_in_context "program", "name", ['fixtures/pgettext.rb:36'] do |t|
      assert_equal "please translate 'name' in the context of 'program'.\n Hint: the translation should NOT contain the translation of 'program'.", t.comment
    end
  end

  def test_glade
    # Old style (~2.0.4)
    ary = GetText::GladeParser.parse('fixtures/gladeparser.glade')

    assert_equal(['window1', 'fixtures/gladeparser.glade:8'], ary[0])
    assert_equal(['normal text', 'fixtures/gladeparser.glade:29'], ary[1])
    assert_equal(['1st line\n2nd line\n3rd line', 'fixtures/gladeparser.glade:50'], ary[2])
    assert_equal(['<span color="red" weight="bold" size="large">markup </span>', 'fixtures/gladeparser.glade:73'], ary[3])
    assert_equal(['<span color="red">1st line markup </span>\n<span color="blue">2nd line markup</span>', 'fixtures/gladeparser.glade:94'], ary[4])
    assert_equal(['<span>&quot;markup&quot; with &lt;escaped strings&gt;</span>', 'fixtures/gladeparser.glade:116'], ary[5])
    assert_equal(['duplicated', 'fixtures/gladeparser.glade:137', 'fixtures/gladeparser.glade:158'], ary[6])
  end

  def fixtures_erb
    @ary = GetText::ErbParser.parse('fixtures/erb.rhtml')

    assert_target 'aaa', ['fixtures/erb.rhtml:8']
    assert_target 'aaa\n', ['fixtures/erb.rhtml:11']
    assert_target 'bbb', ['fixtures/erb.rhtml:12']
    assert_plural_target "ccc1", "ccc2", ['fixtures/erb.rhtml:13']
  end

  def test_rgettext_parse
    GetText::ErbParser.init(:extnames => ['.rhtml', '.rxml'])
    @ary = @rgettext.parse(['fixtures/erb.rhtml'])
    assert_target 'aaa', ['fixtures/erb.rhtml:8']
    assert_target 'aaa\n', ['fixtures/erb.rhtml:11']
    assert_target 'bbb', ['fixtures/erb.rhtml:12']
    assert_plural_target "ccc1", "ccc2", ['fixtures/erb.rhtml:13']

    @ary = @rgettext.parse(['fixtures/erb.rxml'])
    assert_target 'aaa', ['fixtures/erb.rxml:9']
    assert_target 'aaa\n', ['fixtures/erb.rxml:12']
    assert_target 'bbb', ['fixtures/erb.rxml:13']
    assert_plural_target "ccc1", "ccc2", ['fixtures/erb.rxml:14']

    @ary = @rgettext.parse(['fixtures/ngettext.rb'])
    assert_plural_target "ooo", "ppp", ['fixtures/ngettext.rb:66', 'fixtures/ngettext.rb:67']
    assert_plural_target "qqq", "rrr", ['fixtures/ngettext.rb:71', 'fixtures/ngettext.rb:72']
  end

  private

  def assert_target(msgid, sources = nil)
    t = @ary.detect {|elem| elem.msgid == msgid}
    if t
      if sources
        assert_equal sources.sort, t.sources.sort, 'Translation target sources do not match.'
      end
      yield t if block_given?
    else
      flunk "Expected a translation target with id '#{msgid}'. Not found."
    end
  end

  def assert_plural_target(msgid, plural, sources = nil)
    assert_target msgid, sources do |t|
      assert_equal plural, t.msgid_plural, 'Expected plural form'
      yield t if block_given?
    end
  end

  def assert_target_in_context(msgctxt, msgid, sources = nil)
    t = @ary.detect {|elem| elem.msgid == msgid && elem.msgctxt == msgctxt}
    if t
      if sources
        assert_equal sources.sort, t.sources.sort, 'Translation target sources do not match.'
      end
      yield t if block_given?
    else
      flunk "Expected a translation target with id '#{msgid}' and context '#{msgctxt}'. Not found."
    end
  end
end
