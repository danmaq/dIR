#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ランキング並替アイテム情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::RankingOrder;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use DIR::Const;
use DIR::Template;
use DIR::Validate;

$DIR::DB::RankingOrder::VERSION = 0.01;	# バージョン情報

@DIR::DB::RankingOrder::ISA = qw(Exporter);
@DIR::DB::RankingOrder::EXPORT = qw(
	readRankingOrderFromID
	readRankingOrderFromGameID
	writeRankingOrderInsert
	writeRankingOrderUpdate
	eraseRankingOrder
	eraseRankingOrderFromRankID
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	並替アイテムIDからデータベース内の並替アイテム情報を検索します。
# PARAM NUM 並替アイテムID
# RETURN \%(RANK_ID TARGET_COL RANK_ORDER) ランキングID、対象カラム、昇降順フラグ
sub readRankingOrderFromID{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Const::FILE_SQL_RANKING_ORDER_SELECT,
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
#	ランキングIDからデータベース内の並替アイテム情報を検索します。
# PARAM NUM ランキングID
# RETURN @\%(ID TARGET_COL RANK_ORDER) 並替アイテムID、対象カラム、昇降順フラグ
sub readRankingOrderFromGameID{
	my $self = shift;
	my $id = shift;
	my @result = ();
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Const::FILE_SQL_RANKING_ORDER_SELECT_FROM_RID,
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
#	並替アイテム情報をデータベースへ格納します。
# PARAM %(RANK_ID TARGET_COL RANK_ORDER) ランキングID、対象カラム、昇降順フラグ
# RETURN NUM 並替アイテムID。失敗した場合、未定義値。
sub writeRankingOrderInsert{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(RANK_ID TARGET_COL RANK_ORDER)], 1, 1)){
		if(
			$self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_RANKING_ORDER_INSERT), undef,
				$args{RANK_ID},		$args{TARGET_COL},	$args{RANK_ORDER})
		){ $result = $self->selectTableLastID(DIR::Const::FILE_SQL_RANKING_ORDER_SELECT_LAST_ID); }
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースの並替アイテム情報を更新します。
# PARAM %(ID RANK_ID TARGET_COL RANK_ORDER) 並替アイテムID、ランキングID、対象カラム、昇降順フラグ
# RETURN BOOLEAN 成功した場合、真値。
sub writeRankingOrderUpdate{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(ID RANK_ID TARGET_COL RANK_ORDER)], 1)){
		$result = $self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_RANKING_ORDER_UPDATE), undef,
			$args{TARGET_COL},	$args{RANK_ORDER},
			$args{ID},			$args{RANK_ID});
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	並替アイテムをデータベースから抹消します。
# PARAM NUM 並替アイテムID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseRankingOrder{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Const::FILE_SQL_RANKING_ORDER_DELETE), undef, $id);
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	特定ランキングに属する並替アイテムをデータベースから抹消します。
# PARAM NUM ランキングID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseRankingOrderFromRankID{
	my $self = shift;
	my $rid = shift;
	my $result = undef;
	if(defined($rid) and $rid){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Const::FILE_SQL_RANKING_ORDER_DELETE_FROM_RID), undef, $rid);
	}
	return $result;
}

1;

__END__
