#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	TOPページ表示スクリプト。
use 5.006;
use strict;
use warnings;
use lib qw(. ./lib);
use utf8;
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル
my $in = DIR::Input->instance();
my $out = DIR::Output->instance();
$out->putTop(DIR::Game::listNewAll());

DIR::Access->new(account => DIR::User->newExistFromSession(), page_name => 'TOP');
DIR::DB->instance()->dispose();

1;

__END__
