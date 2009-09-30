#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ランキング情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::Ranking;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use Jcode;
use DIR::Const;
use DIR::Template;
use DIR::Validate;

$DIR::DB::Ranking::VERSION = 0.01;	# バージョン情報

@DIR::DB::Ranking::ISA = qw(Exporter);
@DIR::DB::Ranking::EXPORT = qw(
	readRankingFromID
	readRankingFromGameID
	writeRankingInsert
	writeRankingUpdate
	eraseRanking
	eraseRankingFromGameID
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ランキングIDからデータベース内のランキング情報を検索します。
# PARAM NUM ランキングID
# RETURN \%(GAME_ID CAPTION \@VIEW TOP_LIST)
#	ゲーム マスターID、ランキング名、表示フラグ一覧、ランキングTOPにリストを表示するかどうか
sub readRankingFromID{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Const::FILE_SQL_RANKING_SELECT,
			{ type => SQL_INTEGER, value => $id });
		if(ref($sql)){
			my $row = $sql->fetchrow_hashref();
			if(defined($row)){
				$result = {
					GAME_ID		=> $row->{GAME_ID},
					CAPTION		=> Jcode->new($row->{CAPTION}, 'utf8')->ucs2(),
					VIEW		=> [
						$row->{VIEW0}, $row->{VIEW1}, $row->{VIEW2}, $row->{VIEW3},
						$row->{VIEW4}, $row->{VIEW5}, $row->{VIEW6}, $row->{VIEW7},
					],
					TOP_LIST	=> $row->{TOP_LIST}};
			}
			$sql->finish();
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム マスターIDからデータベース内のランキング情報を検索します。
# PARAM NUM ゲーム マスターID
# RETURN @\%(ID CAPTION \@VIEW TOP_LIST)
#	ランキングID、ランキング名、表示フラグ一覧、ランキングTOPにリストを表示するかどうか
sub readRankingFromGameID{
	my $self = shift;
	my $id = shift;
	my @result = ();
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Const::FILE_SQL_RANKING_SELECT_FROM_GID,
			{ type => SQL_INTEGER, value => $id });
		if(ref($sql)){
			while(my $row = $sql->fetchrow_hashref()){
				push(@result, {
					ID		=> $row->{ID},
					CAPTION		=> Jcode->new($row->{CAPTION}, 'utf8')->ucs2(),
					VIEW		=> [
						$row->{VIEW0}, $row->{VIEW1}, $row->{VIEW2}, $row->{VIEW3},
						$row->{VIEW4}, $row->{VIEW5}, $row->{VIEW6}, $row->{VIEW7},
					],
					TOP_LIST	=> $row->{TOP_LIST}});
			}
			$sql->finish();
		}
	}
	return @result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ランキング情報をデータベースへ格納します。
# PARAM %(GAME_ID CAPTION) ゲーム マスターID、ランキング名
# RETURN NUM ランキングID。失敗した場合、未定義値。
sub writeRankingInsert{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(GAME_ID CAPTION)], 1, 1)){
		if(
			$self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_RANKING_INSERT), undef,
				$args{GAME_ID}, Jcode->new($args{CAPTION}, 'ucs2')->utf8())
		){ $result = $self->selectTableLastID(DIR::Const::FILE_SQL_RANKING_SELECT_LAST_ID); }
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースのランキング情報を更新します。
# PARAM %(ID GAME_ID CAPTION VIEW TOP_LIST)
#	ランキングID、ゲーム マスターID、ランキング名、表示フラグ、ランキングTOPにリストを表示するかどうか
# RETURN BOOLEAN 成功した場合、真値。
sub writeRankingUpdate{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(ID GAME_ID CAPTION VIEW TOP_LIST)], 1, 1) and
		ref($args{VIEW}) eq 'ARRAY' and scalar(@{$args{VIEW}}) >= 8
	){
		$result = $self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_RANKING_UPDATE), undef,
			Jcode->new($args{CAPTION}, 'ucs2')->utf8(),
			$args{VIEW}->[0],	$args{VIEW}->[1],	$args{VIEW}->[2], $args{VIEW}->[3],
			$args{VIEW}->[4],	$args{VIEW}->[5],	$args{VIEW}->[6], $args{VIEW}->[7],
			$args{TOP_LIST},	$args{ID},			$args{GAME_ID});
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ランキングをデータベースから抹消します。
# PARAM NUM ランキングID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseRanking{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Const::FILE_SQL_RANKING_DELETE), undef, $id);
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	特定ゲーム マスターに属するランキングをデータベースから抹消します。
# PARAM NUM ゲーム マスターID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseRankingFromGameID{
	my $self = shift;
	my $gid = shift;
	my $result = undef;
	if(defined($gid) and $gid){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Const::FILE_SQL_RANKING_DELETE_FROM_GID), undef, $gid);
	}
	return $result;
}

1;

__END__
