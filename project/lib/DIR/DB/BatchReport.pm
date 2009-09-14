#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	バッチ レポート情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::BatchReport;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use DIR::Template;
use DIR::Validate;

$DIR::DB::BatchReport::VERSION = 0.01;	# バージョン情報

@DIR::DB::BatchReport::ISA = qw(Exporter);
@DIR::DB::BatchReport::EXPORT = qw(
	writeBatchReportStart
	writeBatchReportEnd
	readBatchReportFromID
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	バッチ レポートIDからデータベース内のバッチ レポート情報を検索します。
# PARAM NUM バッチ レポートID
# RETURN \%(NAME STATUS STARTED ENDED NOTES) 名前、終了コード、開始/終了日時、備考
sub readBatchReportFromID{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Template::FILE_SQL_BATCHREPORT_SELECT_FROMID,
		{ type => SQL_INTEGER, value => $id });
		if(ref($sql)){
			my $row = $sql->fetchrow_hashref();
			if(defined($row)){
				my $notes = $row->{NOTES};
				$result = {
					NAME	=> Jcode->new($row->{NAME}, 'utf8')->ucs2(),
					STATUS	=> $row->{STATUS},
					STARTED	=> $row->{STARTED},
					ENDED	=> $row->{ENDED},
					NOTES	=> defined($notes) ? Jcode->new($notes, 'utf8')->ucs2() : undef,
				};
			}
			$sql->finish();
		}
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	バッチ処理開始レポートをデータベースへ格納します。
# PARAM STRING バッチ名
# RETURN NUM バッチ レポートID。失敗した場合、未定義値。
sub writeBatchReportStart{
	my $self = shift;
	my $name = shift;
	my $result = undef;
	if(DIR::Validate::isLengthInRange($name, 1, 255)){
		if(
			$self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_BATCHREPORT_INSERT), undef, 
				Jcode->new($name, 'ucs2')->utf8())
		){ $result = selectTableLastID(DIR::Template::FILE_SQL_BATCHREPORT_SELECT_LASTID); }
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	バッチ処理終了レポートをデータベースへ格納します。
# PARAM %(id status notes) バッチ レポートID、終了ステータスコード、(省略可)詳細メッセージ
# RETURN BOOLEAN 成功した場合、真値。
sub writeBatchReportEnd{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(id status)], 1)){
		if(exists($args{notes})){
			$result = $self->dbi()->do(
				DIR::Template::get(DIR::Template::FILE_SQL_BATCHREPORT_UPDATE_WITH_NOTES), undef,
					$args{status}, Jcode->new($args{notes}, 'ucs2')->utf8(), $args{id});
		}
		else{
			$result = $self->dbi()->do(
				DIR::Template::get(DIR::Template::FILE_SQL_BATCHREPORT_UPDATE_WITHOUT_NOTES), undef,
					$args{status}, $args{id});
		}
	}
}

1;

__END__
