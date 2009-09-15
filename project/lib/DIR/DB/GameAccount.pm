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

###########################################################



###########################################################


1;

__END__
