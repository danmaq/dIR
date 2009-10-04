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

$DIR::Output::Misc::RETRY_AFTER = 0;	# メンテナンス時間

$DIR::Output::Misc::VERSION = 0.01;	# バージョン情報

@DIR::Output::Misc::ISA = qw(Exporter);
@DIR::Output::Misc::EXPORT = qw(
	putMaintenance
	putTop
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	メンテナンス中画面を表示します。
sub putMaintenance{
	my $self = shift;
	my $additional = {-status => '503 Service Unavailable'};
	if($DIR::Output::Misc::RETRY_AFTER){
		$additional->{-retry_after} = $DIR::Output::Misc::RETRY_AFTER;
	}
	$self->_put(
		DIR::Template::getHTT(DIR::Const::FILE_HTT_MAINTENANCE,
			VERSION => Jcode->new(DIR::versionLong())->utf8()),
		$additional);
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
		VERSION			=> Jcode->new(DIR::versionLong())->utf8(),
		$self->getAccountBarInfo()));
}

1;

__END__
