#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ランキング絞込アイテム情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::RankingLimit;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use DIR::Const;
use DIR::Template;
use DIR::Validate;

$DIR::DB::RankingLimit::VERSION = 0.01;	# バージョン情報

@DIR::DB::RankingLimit::ISA = qw(Exporter);
@DIR::DB::RankingLimit::EXPORT = qw(
	readRankingLimitFromID
	readRankingLimitFromGameID
	writeRankingLimitInsert
	writeRankingLimitUpdate
	eraseRankingLimit
	eraseRankingLimitFromGameID
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	絞込アイテムIDからデータベース内の絞込アイテム情報を検索します。
# PARAM NUM 絞込アイテムID
# RETURN \%(RANK_ID TARGET_COL THRESHOLD LO_PASS HI_PASS)
#	ランキングID、対象カラム、閾値、閾値以下許容誤差、閾値以上許容誤差
sub readRankingLimitFromID{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Const::FILE_SQL_RANKING_LIMIT_SELECT,
			{ type => SQL_INTEGER, value => $id });
		if(ref($sql)){
			$result = $sql->fetchrow_hashref();
			$sql->finish();
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ランキングIDからデータベース内の絞込アイテム情報を検索します。
# PARAM NUM ランキングID
# RETURN @\%(ID TARGET_COL THRESHOLD LO_PASS HI_PASS)
#	絞込アイテムID、対象カラム、閾値、閾値以下許容誤差、閾値以上許容誤差
sub readRankingLimitFromGameID{
	my $self = shift;
	my $id = shift;
	my @result = ();
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Const::FILE_SQL_RANKING_LIMIT_SELECT_FROM_RID,
			{ type => SQL_INTEGER, value => $id });
		if(ref($sql)){
			while(my $row = $sql->fetchrow_hashref()){ push(@result, $row); }
			$sql->finish();
		}
	}
	return @result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	絞込アイテム情報をデータベースへ格納します。
# PARAM %(RANK_ID TARGET_COL THRESHOLD LO_PASS HI_PASS)
#	ランキングID、対象カラム、閾値、閾値以下許容誤差、閾値以上許容誤差
# RETURN NUM 絞込アイテムID。失敗した場合、未定義値。
sub writeRankingLimitInsert{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(RANK_ID TARGET_COL THRESHOLD LO_PASS HI_PASS)], 1)){
		if(
			$self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_RANKING_LIMIT_INSERT), undef,
				$args{RANK_ID},		$args{TARGET_COL},	$args{THRESHOLD},
				$args{LO_PASS},	$args{HI_PASS})
		){ $result = $self->selectTableLastID(DIR::Const::FILE_SQL_RANKING_LIMIT_SELECT_LAST_ID); }
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースの絞込アイテム情報を更新します。
# PARAM %(ID RANK_ID TARGET_COL THRESHOLD LO_PASS HI_PASS)
#	絞込アイテムID、ランキングID、対象カラム、閾値、閾値以下許容誤差、閾値以上許容誤差
# RETURN BOOLEAN 成功した場合、真値。
sub writeRankingLimitUpdate{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(ID RANK_ID TARGET_COL THRESHOLD LO_PASS HI_PASS)], 1)){
		$result = $self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_RANKING_LIMIT_UPDATE), undef,
			$args{TARGET_COL},	$args{THRESHOLD},	$args{LO_PASS},
			$args{HI_PASS},	$args{ID},		$args{RANK_ID});
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	絞込アイテムをデータベースから抹消します。
# PARAM NUM 絞込アイテムID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseRankingLimit{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Const::FILE_SQL_RANKING_LIMIT_DELETE), undef, $id);
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	特定ランキングに属する絞込アイテムをデータベースから抹消します。
# PARAM NUM ランキングID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseRankingLimitFromGameID{
	my $self = shift;
	my $rid = shift;
	my $result = undef;
	if(defined($rid) and $rid){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Const::FILE_SQL_RANKING_LIMIT_DELETE_FROM_RID), undef, $rid);
	}
	return $result;
}

1;

__END__
