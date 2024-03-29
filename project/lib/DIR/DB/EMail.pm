#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	電子メールアドレスのデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::EMail;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use DIR::Const;
use DIR::Template;
use DIR::Validate;

$DIR::DB::EMail::VERSION = 0.01;	# バージョン情報

@DIR::DB::EMail::ISA = qw(Exporter);
@DIR::DB::EMail::EXPORT = qw(
	readEMailFromEMail
	readEMailFromUID
	writeEMailInsert
	writeEMailUpdate
	eraseEMail
	eraseEMailFromUserID
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	メールアドレスからデータベース内のメールアドレス情報を検索します。
# PARAM STRING メールアドレス
# RETURN \%(USER_ID EMAIL_VALID NOTIFY_SERVICE NOTIFY_ADS UNDELIVERABLE REGIST_TIME)
#	ユーザ マスタ アカウントID、メール認証コード、dIR通知フラグ、広告フラグ、不達カウント、登録日時
sub readEMailFromEMail{
	my $self = shift;
	my $email = shift;
	my $result = undef;
	if(DIR::Validate::isEMail($email)){
		my $sql = $self->_execute(DIR::Const::FILE_SQL_USER_EMAIL_SELECT_FROM_URI,
		{ type => SQL_VARCHAR, value => $email });
		if(ref($sql)){
			my $row = $sql->fetchrow_hashref();
			if(defined($row)){
				my $notes = $row->{NOTES};
				$result = {
					USER_ID			=> $row->{USER_ID},
					EMAIL_VALID		=> $row->{EMAIL_VALID},
					NOTIFY_SERVICE	=> $row->{NOTIFY_SERVICE},
					NOTIFY_ADS		=> $row->{NOTIFY_ADS},
					UNDELIVERABLE	=> $row->{UNDELIVERABLE},
					REGIST_TIME		=> $row->{REGIST_TIME},
				};
			}
			$sql->finish();
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントIDからメールアドレスを検索します。
# PARAM NUM ユーザ マスター アカウントID
# RETURN @\% メールアドレス全情報
sub readEMailFromUID{
	my $self = shift;
	my $uid = shift;
	my @result = ();
	if(defined($uid) and $uid){
		@result = $self->selectAll(DIR::Const::FILE_SQL_USER_EMAIL_SELECT_FROM_UID, $uid);
	}
	return @result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	メールアドレス情報をデータベースへ格納します。
# PARAM %(id email valid service ads) ユーザ マスタ アカウントID、メールアドレス、認証コード、dIR通知フラグ、広告フラグ
# RETURN BOOLEAN 成功した場合、真値。
sub writeEMailInsert{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(id email valid service ads)], 1) and
		DIR::Validate::isEMail($args{email})
	){
		$result = $self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_USER_EMAIL_INSERT), undef,
			$args{id}, $args{email}, $args{valid}, $args{service}, $args{ads});
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースのメールアドレス情報を更新します。
# PARAM %(id email valid service ads undeliverable)
#	ユーザ マスタ アカウントID、メールアドレス、認証コード、dIR通知フラグ、広告フラグ、不達カウント
# RETURN BOOLEAN 成功した場合、真値。
sub writeEMailUpdate{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(id email valid service ads undeliverable)], 1)){
		$result = $self->dbi()->do(DIR::Template::get(DIR::Const::FILE_SQL_USER_EMAIL_UPDATE), undef,
			$args{valid}, $args{service}, $args{ads}, $args{undeliverable}, $args{id}, $args{email});
	}
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	メールアドレスをデータベースから抹消します。
# PARAM STRING メールアドレス
# RETURN BOOLEAN 成功した場合、真値。
sub eraseEMail{
	my $self = shift;
	my $email = shift;
	my $result = undef;
	if(DIR::Validate::isEMail($email)){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Const::FILE_SQL_USER_EMAIL_DELETE), undef, $email);
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	指定ユーザ マスター アカウントのメールアドレスをデータベースから抹消します。
# PARAM NUM ユーザ マスター アカウントID
# RETURN BOOLEAN 成功した場合、真値。
sub eraseEMailFromUserID{
	my $self = shift;
	my $uid = shift;
	my $result = undef;
	if(defined($uid) and $uid){
		$result = $self->dbi()->do(
			DIR::Template::get(DIR::Const::FILE_SQL_USER_EMAIL_DELETE_FROM_UID), undef, $uid);
	}
	return $result;
}

1;

__END__
