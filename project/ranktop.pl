#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	各ゲームランキングTOPページ表示スクリプト。
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
my $id = $in->getParamRankTop();
my $gamecode = 'unknown';
if(defined($id)){
	$game = DIR::Game->newExistFromID($id);
	if(defined($game)){
		$gamecode = $game->devcode();
		
	}
}
DIR::Access->new(account => undef, page_name => 'RANK_TOP_' . $gamecode, page_number => $pageNumber);
DIR::DB->instance()->dispose();

1;

__END__
