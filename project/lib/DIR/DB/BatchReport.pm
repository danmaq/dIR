#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	バッチレポート入出力クラス。
# ! NOTE : このクラスは、実質CSIM::DBの一部として機能します。
package DIR::DB::BatchReport;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use DIR::Validate;

$DIR::DB::BatchReport::VERSION = 0.01;	# バージョン情報

@DIR::DB::BatchReport::ISA = qw(Exporter);
@DIR::DB::BatchReport::EXPORT = qw(
	writeBatchReportStart
	writeBatchReportEnd
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	バッチ開始レポートをデータベースへ格納します。
# PARAM STRING バッチ名
# RETURN NUM バッチID。
sub writeBatchReportStart{
	my $self = shift;
	my $name = shift;
	my $result = undef;
	if(DIR::Validate::isLengthInRange($name, 1, 255)){
		$self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_BATCHREPORT_INSERT), undef, 
			Jcode->new($name, 'ucs2')->utf8());
		$result = selectTableLastID(DIR::Template::FILE_SQL_BATCHREPORT_SELECT_LASTID);
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	バッチ終了レポートをデータベースへ格納します。
# PARAM %(id status notes) バッチID、終了ステータスコード、(省略可)詳細メッセージ
sub writeBatchReportEnd{
	my $self = shift;
	my %args = @_;
	if(CSIM::Validate::isExistParameter(\%args, [qw(id status)], 1)){
		if(exists($args{notes})){
			$self->dbi()->do(
				DIR::Template::get(DIR::Template::FILE_SQL_BATCHREPORT_UPDATE_WITH_NOTES), undef,
					$args{status}, Jcode->new($args{notes}, 'ucs2')->utf8(), $args{id});
		}
		else{
			$self->dbi()->do(
				DIR::Template::get(DIR::Template::FILE_SQL_BATCHREPORT_UPDATE_WITHOUT_NOTES), undef,
					$args{status}, $args{id});
		}
	}
}

sub readBat

1;

__END__
