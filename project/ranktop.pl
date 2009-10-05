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
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

my $in = DIR::Input->instance();
my $out = DIR::Output->instance();
my $id = $in->getParamRankTop();
my $gamecode = 'unknown';
if(defined($id)){
	my $game = DIR::Game->newExistFromID($id);
	if(defined($game)){
		$gamecode = $game->devcode();
		my @ranks = DIR::Ranking::listNewFromGame($game);
		my @ranksView	= grep { $_->isViewListInTop();			} @ranks;
		my @ranksNoView	= grep { (not $_->isViewListInTop());	} @ranks;
		my @score = ();
		foreach my $rank (@ranksView){ push(@score, [$rank->ranking()]); }
		$out->putRankingTop(
			game	=> $game,
			rank	=> [[@ranksView], [@ranksNoView]],
			score	=> [@score]);
	}
}
DIR::Access->new(account => DIR::User->newExistFromSession(), page_name => 'RANK_TOP_' . $gamecode);
DIR::DB->instance()->dispose();

1;

__END__
