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
use CGI qw(-compile);
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

my $in = DIR::Input->instance();
my $out = DIR::Output->instance();
my $pageName;
my $pageNumber = undef;

my @games = DIR::Game::listNewAll();
$pageName = 'TOP';
$out->putTop(
	games => \@games
);

DIR::Access->new(account => undef, page_name => $pageName, page_number => $pageNumber);
DIR::DB->instance()->dispose();

1;

__END__
