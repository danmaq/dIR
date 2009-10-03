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
my $id = $in->getParamRankDescription();
my $gamecode = 'unknown';
my $rankID = 0;
if(defined($id)){
	my $rank = DIR::Ranking->newExist($id);
	if(defined($rank)){
		my $game = $rank->game();
		$gamecode = $game->devcode();
		$rankID = $rank->id();
		my @ranks = grep {$_->id() != $rank->id()} DIR::Ranking::listNewFromGame($game);
		$out->putRankingDescription(
			game	=> $game,
			target	=> $rank,
			others	=> [@ranks],
			score	=> [$rank->ranking()]);
	}
}
DIR::Access->new(account => undef, page_name => sprintf('RANK_DESC_%s-%d', $gamecode, $rankID));
DIR::DB->instance()->dispose();

1;

__END__
