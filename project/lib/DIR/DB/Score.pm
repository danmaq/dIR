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
use DIR::Template;
use DIR::Validate;

$DIR::DB::Score::VERSION = 0.01;	# バージョン情報

@DIR::DB::Score::ISA = qw(Exporter);
@DIR::DB::Score::EXPORT = qw(
	readScoreFromID
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
		my $sql = $self->_execute(DIR::Template::FILE_SQL_SCORE_SELECT_FROM_ID,
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
		DIR::Validate::isExistParameter(\%args,
			[qw(user_id dev_code title validator_uri registable_on_browser)], 1) and
		$self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_SCORE_INSERT), undef, 
			$args{user_id}, $args{dev_code},
			Jcode->new($args{title}, 'ucs2')->utf8(),
			$args{validator_uri}, $args{registable_on_browser})
	){ $result = selectTableLastID(DIR::Template::FILE_SQL_SCORE_SELECT_LAST_ID); }
	return $result;
}

1;

__END__
