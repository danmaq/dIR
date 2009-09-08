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
use DIR::Template;
use DIR::Validate;

$DIR::DB::User::VERSION = 0.01;	# バージョン情報

@DIR::DB::User::ISA = qw(Exporter);
@DIR::DB::User::EXPORT = qw(
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

1;

__END__
