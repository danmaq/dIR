#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	スコア情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::Score;
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

$DIR::DB::Score::VERSION = 0.01;	# バージョン情報

@DIR::DB::Score::ISA = qw(Exporter);
@DIR::DB::Score::EXPORT = qw(
	readScoreFromID
	writeScoreInsert
	writeScoreUpdate
	eraseScore
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	スコアIDからデータベース内のスコア情報を検索します。
# PARAM NUM スコアID
# RETURN \%(GACCOUNT_ID PASSWD \@SCORE INJUSTICE WITHDRAW REGIST_TIME REMOTE_ADDR REMOTE_HOST USER_AGENT NOTES)
#	ゲーム アカウントID、スコア認証コード、スコア一覧、不正フラグ、非公開フラグ、
#	登録日時、リモートIPアドレス、リモートホスト、エージェント名、備考
sub readScoreFromID{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Const::FILE_SQL_SCORE_SELECT_FROM_ID,
			{type => SQL_INTEGER, value => $id});
		if(ref($sql)){
			my $row = $sql->fetchrow_hashref();
			if(defined($row)){
				my $notes = $row->{NOTES};
				$result = {
					GACCOUNT_ID	=> $row->{GACCOUNT_ID},
					PASSWD		=> $row->{PASSWD},
					SCORE		=> [
						$row->{SCORE0},	$row->{SCORE1},	$row->{SCORE2},	$row->{SCORE3},
						$row->{SCORE4},	$row->{SCORE5},	$row->{SCORE6},	$row->{SCORE7},
					],
					INJUSTICE	=> $row->{INJUSTICE},
					WITHDRAW	=> $row->{WITHDRAW},
					REGIST_TIME	=> $row->{REGIST_TIME},
					REMOTE_ADDR	=> $row->{REMOTE_ADDR},
					REMOTE_HOST	=> $row->{REMOTE_HOST},
					USER_AGENT	=> $row->{USER_AGENT},
					NOTES		=> defined($notes) ? Jcode->new($notes, 'utf8')->ucs2() : undef,
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
#	スコア情報をデータベースへ格納します。
# PARAM %(GACCOUNT_ID PASSWD \@SCORE REMOTE_ADDR REMOTE_HOST USER_AGENT)
#	ゲーム アカウントID、スコア認証コード、スコア一覧、リモートIPアドレス、リモートホスト、エージェント名
# RETURN NUM スコアID。失敗した場合、未定義値。
sub writeScoreInsert{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(GACCOUNT_ID PASSWD SCORE REMOTE_ADDR)], 1, 1) and
		DIR::Validate::isExistParameter(\%args, [qw(REMOTE_HOST USER_AGENT)], 1) and
		scalar(@{$args{SCORE}}) >= 8 and
		$self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_SCORE_INSERT), undef, 
			$args{GACCOUNT_ID}, $args{PASSWD}, $args{SCORE}->[0], $args{SCORE}->[1],
			$args{SCORE}->[2], $args{SCORE}->[3], $args{SCORE}->[4], $args{SCORE}->[5],
			$args{SCORE}->[6], $args{SCORE}->[7], $args{REMOTE_ADDR}, $args{REMOTE_HOST},
			$args{USER_AGENT})
	){ $result = $self->selectTableLastID(DIR::Const::FILE_SQL_SCORE_SELECT_LAST_ID); }
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	スコア情報をデータベースへ格納します。
# PARAM %(ID INJUSTICE WITHDRAW NOTES) スコアID、不正フラグ、非公開フラグ、備考
# RETURN BOOLEAN 成功した場合、真値。
sub writeScoreUpdate{
	my $self = shift;
	my %args = @_;
	return (
		DIR::Validate::isExistParameter(\%args, [qw(ID INJUSTICE WITHDRAW)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(NOTES)]) and
		$self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_SCORE_UPDATE), undef,
			$args{INJUSTICE}, $args{WITHDRAW},
			defined($args{NOTES}) ? Jcode->new($args{NOTES}, 'ucs2')->utf8() : undef, $args{ID})
	);
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	スコア情報をデータベースから抹消します。
# PARAM NUM スコアID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseScore{
	my $self = shift;
	my $id = shift;
	return (
		defined($id) and $id and
		$self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_SCORE_DELETE), undef, $id)
	);
}

1;

__END__
