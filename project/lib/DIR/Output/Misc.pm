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
	$self->_put(DIR::Template::getHTT(DIR::Template::FILE_HTT_MAINTENANCE,
		VERSION => Jcode->new(DIR::versionLong())->utf8()));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	トップページ画面を表示します。
# PARAM %()
sub putTop{
	my $self = shift;
	my %param = @_;
	$self->putMaintenance();

}

1;

__END__
