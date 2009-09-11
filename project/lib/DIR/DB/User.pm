#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ユーザ マスター アカウント情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質CSIM::DBの一部として機能します。
package DIR::DB::User;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use Jcode;
use DIR::Template;
use DIR::Validate;

$DIR::DB::User::VERSION = 0.01;	# バージョン情報

@DIR::DB::User::ISA = qw(Exporter);
@DIR::DB::User::EXPORT = qw(
	readUserFromID
	writeUserNew
	writeUserRenew
	writeUserLogin
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントIDからデータベース内の
#	ユーザ マスター アカウント情報を検索します。
# PARAM NUM ユーザ マスター アカウントID
# RETURN \%(PASSWD NICKNAME INTRODUCTION REGIST_TIME RENEW_TIME LOGIN_TIME LOGIN_COUNT NOTES)
#	パスワード、ニックネーム、自己紹介、登録/更新/ログイン日時、ログイン回数、備考
sub readUserFromID{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $sql = $self->_execute(DIR::Template::FILE_SQL_USER_SELECT_FROMID,
		{ type => SQL_INTEGER, value => $id });
		if(ref($sql)){
			my $row = $sql->fetchrow_hashref();
			if(defined($row)){
				my $notes = $row->{NOTES};
				$result = {
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
#	ユーザ マスター アカウント情報をデータベースへ格納します。
# PARAM %(id password nickame introduction) ID、パスワード、ニックネーム、自己紹介
# RETURN BOOLEAN 成功した場合、真値。
sub writeUserNew{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(id password nickame introduction)], 1)){
		$result = $self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_USER_INSERT), undef,
			$args{id}, $args{password},
			Jcode->new($args{nickame},		'ucs2')->utf8(),
			Jcode->new($args{introduction},	'ucs2')->utf8());
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースのユーザ マスター アカウント情報を更新します。
# PARAM %(id password nickame introduction notes) ID、パスワード、ニックネーム、自己紹介、備考
# RETURN BOOLEAN 成功した場合、真値。
sub writeUserRenew{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(id password nickame introduction)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(notes)])
	){
		my $notes = $args{notes};
		$result = $self->dbi()->do(DIR::Template::get(DIR::Template::FILE_SQL_USER_UPDATE), undef,
			$args{password},
			Jcode->new($args{nickame},				'ucs2')->utf8(),
			Jcode->new($args{introduction},			'ucs2')->utf8(),
			defined($notes) ? Jcode->new($notes,	'ucs2')->utf8() : undef,
			$args{id});
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースのログイン情報を更新します。
# PARAM NUM ユーザ マスター アカウントID
# RETURN BOOLEAN 成功した場合、真値。
sub writeUserLogin{
	my $self = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id =~ /^[0-9]+$/){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Template::FILE_SQL_USER_UPDATE_LOGIN), undef, $id);
	}
	return $result;
}

1;

__END__
