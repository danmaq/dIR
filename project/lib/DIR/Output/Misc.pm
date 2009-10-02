#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	既存カテゴリに該当しない雑多なWeb出力を司るクラス。
# ! NOTE : このクラスは、実質DIR::Outputの一部として機能します。
package DIR::Output::Misc;
use 5.006;
use strict;
use warnings;
use utf8;
use Exporter;
use Jcode;
use DIR::Const;
use DIR::Template;

$DIR::Output::Misc::VERSION = 0.01;	# バージョン情報

@DIR::Output::Misc::ISA = qw(Exporter);
@DIR::Output::Misc::EXPORT = qw(
	putMaintenance
	putTop
	putRankingTop
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	メンテナンス中画面を表示します。
sub putMaintenance{
	my $self = shift;
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_MAINTENANCE,
		VERSION => Jcode->new(DIR::versionLong())->utf8()));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	トップページ画面を表示します。
# PARAM @\% 全ゲーム マスター情報一覧
sub putTop{
	my $self = shift;
	my $games = [];
	foreach my $game (@_){
		push(@$games, {
			GAME_ID			=> $game->id(),
			GAME_NAME		=> Jcode->new($game->title(), 'ucs2')->utf8(),
			PUB_URL			=> $game->publisher()->uri(),
			PUB_NAME		=> Jcode->new($game->publisher()->coName(), 'ucs2')->utf8(),
			GAME_REGISTED	=> $self->_createTimeStamp($game->registed()),
			MODE			=> DIR::Const::MODE_RANK_TOP});
	}
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_TOP,
		GAMES			=> $games,
		GAMES_EXISTS	=> scalar(@$games),
		VERSION			=> Jcode->new(DIR::versionLong())->utf8()));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	各ゲームのランキングトップページ画面を表示します。
# PARAM %(game \@rank[2] \@score)
#	ゲーム マスター情報、ランキング情報一覧[表示,非表示]、スコア本体
sub putRankingTop{
	my $self = shift;
	my %args = @_;
	my $countRankView = scalar(@{$args{rank}->[0]});
	my $countRankHide = scalar(@{$args{rank}->[1]});
	my $infoRankingView = [];
	my $infoRankingHide = [];
	for(my $i = 0; $i < $countRankView; $i++){
		my $rank = $args{rank}->[1]->[$i];
		push(@$infoRankingView, {
			RANKING_EXISTS	=> 0,
			GAME_ID			=> $args{game}->id(),
			RANKING_ID		=> $rank->id(),
			RANKING_NAME	=> Jcode->new($rank->caption(), 'ucs2')->utf8(),
			MODE			=> DIR::Const::MODE_RANK_DESCRIPTION});
	}
	foreach my $rank (@{$args{rank}->[1]}){
		push(@$infoRankingHide, {
			GAME_ID			=> $args{game}->id(),
			RANKING_ID		=> $rank->id(),
			RANKING_NAME	=> Jcode->new($rank->caption(), 'ucs2')->utf8(),
			MODE			=> DIR::Const::MODE_RANK_DESCRIPTION});
	}
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_RANK_TOP,
		GAME_HOME_URL		=> $args{game}->homeURI(),
		GAME_NAME			=> Jcode->new($args{game}->title(), 'ucs2')->utf8(),
		RANKING_EXISTS		=> $countRankView + $countRankHide,
		RANKING_VIEW_EXISTS	=> $countRankView,
		RANKING_HIDE_EXISTS	=> $countRankHide,
		RANKING_HIDE		=> $infoRankingHide,
	));
}

1;

__END__
