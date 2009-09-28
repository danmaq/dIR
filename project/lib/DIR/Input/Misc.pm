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
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	ランキングTOPページのゲームIDを取得します。
# RETURN NUM ゲームID
sub getParamRankTop{
	my $self = shift;
	my $result = $self->cgi()->param('id');
	return (defined($result) and $result =~ /^[0-9]+$/ ? $result : undef);
}

1;

__END__
