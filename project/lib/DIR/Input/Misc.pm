#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	既存カテゴリに該当しない雑多なWeb入力を司るクラス。
# ! NOTE : このクラスは、実質DIR::Inputの一部として機能します。
package DIR::Input::Misc;
use 5.006;
use strict;
use warnings;
use utf8;
use Exporter;

$DIR::Input::Misc::VERSION = 0.01;	# バージョン情報

@DIR::Input::Misc::ISA = qw(Exporter);
@DIR::Input::Misc::EXPORT = qw(
	getParamRankTop
	getParamRankDescription
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	ランキングTOPページのクエリ情報を取得します。
# RETURN NUM ゲームID
sub getParamRankTop{
	my $self = shift;
	return _getGameMasterID($self);
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	ランキング詳細ページのクエリ情報を取得します。
# RETURN NUM ランキング定義ID
sub getParamRankDescription{
	my $self = shift;
	return _getRankingDefineID($self);
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PRIVATE STATIC
# 	ゲーム マスターIDを取得します。
# RETURN NUM ゲーム マスターID
sub _getGameMasterID{
	my $self = shift;
	return $self->getNumber('g');
}

#----------------------------------------------------------
# PRIVATE STATIC
# 	ランキング定義IDを取得します。
# RETURN NUM ゲームID
sub _getRankingDefineID{
	my $self = shift;
	return $self->getNumber('r');
}

1;

__END__
