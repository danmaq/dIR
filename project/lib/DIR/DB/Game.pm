#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ゲーム マスター情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::Game;
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

$DIR::DB::Game::VERSION = 0.01;	# バージョン情報

@DIR::DB::Game::ISA = qw(Exporter);
@DIR::DB::Game::EXPORT = qw(
	readGameFromID
	readGameFromUID
	readGameAll
	writeGameInsert
	writeGameUpdate
	eraseGame
	eraseGameFromPublisherID
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム マスターIDからデータベース内のゲーム マスター情報を検索します。
# PARAM NUM ゲーム マスターID
# RETURN \%(PUB_ID DEVCODE TITLE HOME_URI VALIDATOR REG_BROWSER \@SCORE_NAME REGIST_TIME NOTES)
#	パブリッシャーID、開発コード、タイトル、ホームURL、スコア検証URL、
#	Webブラウザから登録可能かどうか、スコア名称一覧、登録日時、備考
sub readGameFromID{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Const::FILE_SQL_GAME_SELECT_FROM_ID,
			{type => SQL_INTEGER, value => $id});
		if(ref($sql)){
			my $row = $sql->fetchrow_hashref();
			if(defined($row)){
				my $notes = $row->{NOTES};
				$result = {
					PUB_ID		=> $row->{PUB_ID},
					DEVCODE		=> $row->{DEVCODE},
					TITLE		=> Jcode->new($row->{TITLE}, 'utf8')->ucs2(),
					HOME_URI	=> $row->{HOME_URI},
					VALIDATOR	=> $row->{VALIDATOR},
					REG_BROWSER	=> $row->{REG_BROWSER},
					SCORE_NAME	=> [
						$row->{SCORENAME0}, $row->{SCORENAME1}, $row->{SCORENAME2},
						$row->{SCORENAME3}, $row->{SCORENAME4}, $row->{SCORENAME5},
						$row->{SCORENAME6}, $row->{SCORENAME7},
					],
					REGIST_TIME	=> $row->{REGIST_TIME},
					NOTES		=> defined($notes) ? Jcode->new($notes, 'utf8')->ucs2() : undef,
				};
			}
			$sql->finish();
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントIDからゲーム マスターIDを検索します。
# PARAM NUM ユーザ マスター アカウントID
# RETURN @NUM ゲーム マスターID
sub readGameFromUID{
	my $self = shift;
	my $uid = shift;
	my @result = ();
	if(defined($uid) and $uid){
		@result = $self->selectAllSingleColumn(DIR::Const::FILE_SQL_GAME_SELECT_FROM_UID,
			'ID', $uid);
	}
	return @result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム全件を検索します。
# RETURN @\% ゲーム全情報
sub readGameAll{
	my $self = shift;
	my @result = ();
	my $sql = $self->_execute(DIR::Const::FILE_SQL_GAME_SELECT);
	if(ref($sql)){
		while(my $row = $sql->fetchrow_hashref()){
			my $notes = $row->{NOTES};
			push(@result, {
				ID			=> $row->{ID},
				PUB_ID		=> $row->{PUB_ID},
				DEVCODE		=> $row->{DEVCODE},
				TITLE		=> Jcode->new($row->{TITLE}, 'utf8')->ucs2(),
				HOME_URI	=> $row->{HOME_URI},
				VALIDATOR	=> $row->{VALIDATOR},
				REG_BROWSER	=> $row->{REG_BROWSER},
				SCORE_NAME	=> [
					$row->{SCORENAME0}, $row->{SCORENAME1}, $row->{SCORENAME2}, $row->{SCORENAME3},
					$row->{SCORENAME4}, $row->{SCORENAME5}, $row->{SCORENAME6}, $row->{SCORENAME7},
				],
				REGIST_TIME	=> $row->{REGIST_TIME},
				NOTES		=> defined($notes) ? Jcode->new($notes, 'utf8')->ucs2() : undef,
			});
		}
		$sql->finish();
	}
	return @result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム マスター情報をデータベースへ格納します。
# PARAM %(user_id dev_code title home_uri validator_uri registable_on_browser)
#	ユーザ マスター アカウントID、開発コード、タイトル、ホームURL、検証URL、Webブラウザから登録可能かどうか
# RETURN NUM ゲーム マスターID。失敗した場合、未定義値。
sub writeGameInsert{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args,
			[qw(user_id dev_code title home_uri validator_uri registable_on_browser)], 1) and
		$self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_GAME_INSERT), undef, 
			$args{user_id}, $args{dev_code},
			Jcode->new($args{title}, 'ucs2')->utf8(),
			$args{home_uri}, $args{validator_uri}, $args{registable_on_browser})
	){ $result = $self->selectTableLastID(DIR::Const::FILE_SQL_GAME_SELECT_LAST_ID); }
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースのゲーム マスター情報を更新します。
# PARAM %(id user_id dev_code title home_uri validator_uri registable_on_browser \@score_name notes)
#	ゲーム マスターID、ユーザ マスター アカウントID、開発コード、タイトル、
#	ホームURL、検証URL、Webブラウザから登録可能かどうか、スコア名称一覧、備考
# RETURN BOOLEAN 成功した場合、真値。
sub writeGameUpdate{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(id user_id dev_code title home_uri validator_uri registable_on_browser score_name)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(notes)]) and
		ref($args{score_name}) eq 'ARRAY' and scalar($args{score_name}) >= 8
	){
		my $notes = $args{notes};
		$result = $self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_GAME_UPDATE), undef,
			$args{dev_code},
			Jcode->new($args{title}, 'ucs2')->utf8(),
			$args{home_uri},
			$args{validator_uri},
			$args{registable_on_browser},
			$args{score_name}->[0], $args{score_name}->[1], $args{score_name}->[2],
			$args{score_name}->[3], $args{score_name}->[4], $args{score_name}->[5],
			$args{score_name}->[6], $args{score_name}->[7],
			defined($notes) ? Jcode->new($notes, 'ucs2')->utf8() : undef,
			$args{id}, $args{user_id});
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム マスターをデータベースから抹消します。
# PARAM NUM ゲーム マスターID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseGame{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		$result =
			$self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_GAME_DELETE), undef, $id);
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	特定パブリッシャーのゲーム マスターをデータベースから抹消します。
# PARAM NUM パブリッシャーID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseGameFromPublisherID{
	my $self = shift;
	my $pid = shift;
	my $result = undef;
	if(defined($pid) and $pid){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Const::FILE_SQL_GAME_DELETE_FROM_PID), undef, $pid);
	}
	return $result;
}

1;

__END__
