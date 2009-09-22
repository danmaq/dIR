#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	各ゲーム アカウント情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::GameAccount;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use Jcode;
use DIR::Template;
use DIR::Validate;

$DIR::DB::GameAccount::VERSION = 0.01;	# バージョン情報

@DIR::DB::GameAccount::ISA = qw(Exporter);
@DIR::DB::GameAccount::EXPORT = qw(
	readGameAccountFromID
	readGameAccountIDFromGameAndUser
	writeGameAccountNew
	writeGameAccountRenew
	writeUserLogin
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	各ゲーム アカウントIDからデータベース内のゲーム情報を検索します。
# PARAM NUM 各ゲーム アカウントID
# RETURN \%(USER_ID GAME_ID PASSWD NICKNAME INTRODUCTION REGIST_TIME RENEW_TIME LOGIN_TIME LOGIN_COUNT NOTES)
#	ユーザ マスター アカウントID、ゲーム マスターID、パスワード、ニックネーム、
#	自己紹介、登録日時、最終更新日時、最終ログイン日時、ログイン回数、備考
sub readGameAccountFromID{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Template::FILE_SQL_GAMEACCOUNT_SELECT_FROM_ID,
			{type => SQL_INTEGER, value => $id});
		if(ref($sql)){
			my $row = $sql->fetchrow_hashref();
			if(defined($row)){
				my $notes = $row->{NOTES};
				$result = {
					USER_ID			=> $row->{USER_ID},
					GAME_ID			=> $row->{GAME_ID},
					PASSWD			=> $row->{PASSWD},
					NICKNAME		=> Jcode->new($row->{NICKNAME},		'utf8')->ucs2(),
					INTRODUCTION	=> Jcode->new($row->{INTRODUCTION},	'utf8')->ucs2(),
					REGIST_TIME		=> $row->{REGIST_TIME},
					RENEW_TIME		=> $row->{RENEW_TIME},
					LOGIN_TIME		=> $row->{LOGIN_TIME},
					LOGIN_COUNT		=> $row->{LOGIN_COUNT},
					NOTES			=> defined($notes) ? Jcode->new($notes, 'utf8')->ucs2() : undef,
				};
			}
			$sql->finish();
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントIDとゲーム マスターIDからゲーム アカウントIDを検索します。
# PARAM %(user_id game_id) ユーザ マスター アカウントID、ゲーム マスターID
# RETURN NUM ゲーム アカウントID
sub readGameAccountIDFromGameAndUser{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(user_id game_id)], 1, 1)){
		$result = $self->selectSingleColumn(DIR::Template::FILE_SQL_GAMEACCOUNT_SELECT_GAME_AND_USER,
			'ID', $args{game_id}, $args{user_id});
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム アカウント情報をデータベースへ格納します。
# PARAM %(id user_id game_id password nickname introduction)
#	ゲーム アカウントID、ユーザ マスター アカウントID、ゲーム マスターID、パスワード、ニックネーム、自己紹介
# RETURN BOOLEAN 成功した場合、真値。
sub writeGameAccountNew{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(id user_id game_id password nickname introduction)], 1)){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Template::FILE_SQL_GAMEACCOUNT_INSERT), undef,
			$args{id}, $args{user_id}, $args{game_id}, $args{password},
			Jcode->new($args{nickame},		'ucs2')->utf8(),
			Jcode->new($args{introduction},	'ucs2')->utf8());
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースのゲーム アカウント情報を更新します。
# PARAM %(id user_id game_id password nickame introduction notes)
#	ゲーム アカウントID、ユーザ マスター アカウントID、ゲーム マスターID、パスワード、ニックネーム、自己紹介、備考
# RETURN BOOLEAN 成功した場合、真値。
sub writeGameAccountRenew{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(id user_id game_id password nickame introduction)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(notes)])
	){
		my $notes = $args{notes};
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Template::FILE_SQL_GAMEACCOUNT_UPDATE), undef,
			$args{password},
			Jcode->new($args{nickame},				'ucs2')->utf8(),
			Jcode->new($args{introduction},			'ucs2')->utf8(),
			defined($notes) ? Jcode->new($notes,	'ucs2')->utf8() : undef,
			$args{id}, $args{user_id}, $args{game_id});
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースのログイン情報を更新します。
# PARAM %(id user_id game_id) ゲーム アカウントID、ユーザ マスター アカウントID、ゲーム マスターID
# RETURN BOOLEAN 成功した場合、真値。
sub writeGameAccountLogin{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(id user_id game_id)], 1, 1)){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Template::FILE_SQL_GAMEACCOUNT_UPDATE_LOGIN), undef,
				$args{id}, $args{user_id}, $args{game_id});
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム アカウントをデータベースから抹消します。
# PARAM NUM ゲーム アカウントID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseGameAccount{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Template::FILE_SQL_GAMEACCOUNT_DELETE), undef, $id);
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	特定ゲームのゲーム アカウントをデータベースから抹消します。
# PARAM NUM ゲーム マスターID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseGameAccountFromGameID{
	my $self = shift;
	my $gid = shift;
	my $result = undef;
	if(defined($gid) and $gid){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Template::FILE_SQL_GAMEACCOUNT_DELETE_FROM_GID), undef, $gid);
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	特定ユーザ マスター アカウントのゲーム アカウントをデータベースから抹消します。
# PARAM NUM ユーザ マスター アカウントID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseGameAccountFromUserID{
	my $self = shift;
	my $uid = shift;
	my $result = undef;
	if(defined($uid) and $uid){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Template::FILE_SQL_GAMEACCOUNT_DELETE_FROM_UID), undef, $uid);
	}
	return $result;
}

1;

__END__
