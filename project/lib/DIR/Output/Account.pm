#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	アカウント周りのWeb出力を司るクラス。
# ! NOTE : このクラスは、実質DIR::Outputの一部として機能します。
package DIR::Output::Account;
use 5.006;
use strict;
use warnings;
use utf8;
use Exporter;
use Jcode;
use DIR::Const;
use DIR::Template;
use DIR::User;

$DIR::Output::Account::VERSION = 0.01;	# バージョン情報

@DIR::Output::Account::ISA = qw(Exporter);
@DIR::Output::Account::EXPORT = qw(
	getAccountBarInfo
	putAccountLogin
	putAccountFailed
	putAccountCheckCookieRedirect
	putAccountTopRedirect
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	アカウントバーの情報を作成します。
# PARAM \% (省略可)ユーザ マスター アカウント情報
# PARAM % アカウントバーの情報。
sub getAccountBarInfo{
	my $self = shift;
	my $user = shift;
	my %result = (MODE_ACCOUNT => DIR::Const::MODE_ACCOUNT_TOP);
	unless(defined($user)){ $user = DIR::User->newExistFromSession(); }
	$result{LOGIN} = (defined($user) and not $user->guest());
	if($result{LOGIN}){
		$result{USER_NAME} = Jcode->new($user->nickname(), 'ucs2')->utf8();
		$result{MODE_LOGOUT} = DIR::Const::MODE_ACCOUNT_LOGOUT;
	}
	return %result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	アカウントログイン/サインアップ画面を表示します。
sub putAccountLogin{
	my $self = shift;
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_ACCOUNT_LOGIN,
		LOGON_MODE	=> DIR::Const::MODE_ACCOUNT_LOGIN,
		SIGNUP_MODE	=> DIR::Const::MODE_ACCOUNT_SIGNUP,
	));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	アカウントログイン/サインアップ失敗画面を表示します。
sub putAccountFailed{
	my $self = shift;
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_ACCOUNT_FAILED,
		$self->getAccountBarInfo()));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	アカウントログイン/サインアップ画面を表示します。
sub putAccountCheckCookieRedirect{
	my $self = shift;
	$self->_redirect(sprintf('/?q=%d', DIR::Const::MODE_ACCOUNT_LOGIN_CHECKSESSION));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	アカウントログイン/サインアップ画面を表示します。
sub putAccountTopRedirect{
	my $self = shift;
	$self->_redirect(sprintf('/?q=%d', DIR::Const::MODE_ACCOUNT_TOP));
}

1;

__END__
