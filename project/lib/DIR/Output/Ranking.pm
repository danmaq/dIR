#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ランキング周りのWeb出力を司るクラス。
# ! NOTE : このクラスは、実質DIR::Outputの一部として機能します。
package DIR::Output::Ranking;
use 5.006;
use strict;
use warnings;
use utf8;
use Exporter;
use Jcode;
use DIR::Const;
use DIR::Template;

$DIR::Output::Ranking::VERSION = 0.01;	# バージョン情報

@DIR::Output::Ranking::ISA = qw(Exporter);
@DIR::Output::Ranking::EXPORT = qw(
	putRankingTop
	putRankingDescription
);

#==========================================================
#==========================================================

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
	for(my $i = 0; $i < $countRankView; $i++){
		my $rank = $args{rank}->[0]->[$i];
		my $info = _createRankingBody($self, $rank, $args{score}->[$i]);
		$info->{RANKING_ID}	= $rank->id();
		$info->{MODE}		= DIR::Const::MODE_RANK_DESCRIPTION;
		push(@$infoRankingView, $info);
	}
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_RANK_TOP,
		RANKING_EXISTS		=> $countRankView + $countRankHide,
		RANKING_VIEW_EXISTS	=> $countRankView,
		RANKING_HIDE_EXISTS	=> $countRankHide,
		RANKING_HIDE		=> _createRankingDescLinkList($args{rank}->[1]),
		RANKING_VIEW		=> $infoRankingView,
		_createRankingEntryLinkList($args{game}),
		$self->getAccountBarInfo()));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	各ゲームのランキング詳細ページ画面を表示します。
# PARAM %(game target \@others \@score)
#	ゲーム マスター情報、表示するランキング情報一覧、その他のランキング情報一覧、スコア本体
sub putRankingDescription{
	my $self = shift;
	my %args = @_;
	my $info = _createRankingBody($self, $args{target}, $args{score});
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_RANK_DESCRIPTION,
		RANKING_OTHERS_EXISTS	=> length(@{$args{others}}),
		RANKING_OTHERS			=> _createRankingDescLinkList($args{others}),
		_createRankingEntryLinkList($args{game}),
		%$info, $self->getAccountBarInfo()));
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PRIVATE STATIC
# 	各ゲームのランキングエントリーページへのリンクに必要な情報を作成します。
# PARAM \% ゲーム マスター情報
# RETURN %(RANKING_BROWSER_ENTRY GAME_HOME_URL GAME_NAME MODE_RANK_ENTRY GAME_ID)
sub _createRankingEntryLinkList{
	my $game = shift;
	return (
		RANKING_BROWSER_ENTRY	=> $game->isRegistableOnBrowser(),
		GAME_HOME_URL			=> $game->homeURI(),
		GAME_NAME				=> Jcode->new($game->title(), 'ucs2')->utf8(),
		MODE_RANK_ENTRY			=> DIR::Const::MODE_RANK_ENTRY,
		GAME_ID					=> $game->id(),
	);
}

#----------------------------------------------------------
# PRIVATE STATIC
# 	各ゲームのランキング詳細ページへのリンクに必要な情報を作成します。
# PARAM \@ ランキング情報一覧
# RETURN \@\%(RANKING_ID RANKING_NAME MODE) ランキング定義ID、ランキング定義名、モード番号
sub _createRankingDescLinkList{
	my $args = shift;
	my $result = [];
	foreach my $rank (@$args){
		push(@$result, {
			RANKING_ID		=> $rank->id(),
			RANKING_NAME	=> Jcode->new($rank->caption(), 'ucs2')->utf8(),
			MODE			=> DIR::Const::MODE_RANK_DESCRIPTION});
	}
	return $result;
}

#----------------------------------------------------------
# PRIVATE STATIC
# 	各ゲームのランキング本体を作成します。
# PARAM \% インスタンス
# PARAM \% ランキング情報
# PARAM \% スコア本体
# RETURN \%(RANKING_EXISTS RANKING_COLS RANKING_ROWS) スコア件数、スコア名一覧、スコア本体
sub _createRankingBody{
	my $self = shift;
	my $rank = shift;
	my $scoreBody = shift;
	my $rowLength = scalar(@$scoreBody);
	my @rankCaption = ();
	my @rankRows = ();
	if($rowLength){
		foreach my $name ($rank->viewScoreColumnName()){ push(@rankCaption, {NAME => $name}); }
		for(my $j = 0; $j < $rowLength; $j++){
			my @score = ();
			foreach my $value (@{$scoreBody->[$j]->{score_list}}){
				push(@score, {VALUE => $value});
			}
			push(@rankRows, {
				COUNT			=> $j,
				NICKNAME		=> Jcode->new($scoreBody->[$j]->{nickname},		'ucs2')->utf8(),
				INTRODUCTION	=> Jcode->new($scoreBody->[$j]->{introduction},	'ucs2')->utf8(),
				REGISTED		=> $self->_createTimeStamp($scoreBody->[$j]->{registed}),
				LOGIN_COUNT		=> $scoreBody->[$j]->{login_count},
				SCORE_LIST		=> [@score]});
		}
	}
	return {
		RANKING_EXISTS	=> $rowLength,
		RANKING_COLS	=> [@rankCaption],
		RANKING_ROWS	=> [@rankRows],
		RANKING_NAME	=> Jcode->new($rank->caption(), 'ucs2')->utf8(),
	};
}

1;

__END__
