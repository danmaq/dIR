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
use DIR::Misc;
use DIR::Template;
use DIR::User;

$DIR::Output::Account::VERSION = 0.01;	# バージョン情報

@DIR::Output::Account::ISA = qw(Exporter);

@DIR::Output::Account::EXPORT = qw(
	getAccountBarInfo
	putAccountLogin
	putAccountTop
	putAccountFailed
	putAccountSignupSucceeded
	putAccountCheckCookieRedirect
	putAccountTopRedirect
	putAccountPassword
	putAccountNickname
	putAccountEMail
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
# 	アカウント設定画面を表示します。
# PARAM \% ユーザ マスター アカウント情報
sub putAccountTop{
	my $self = shift;
	my $user = shift;
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_ACCOUNT_TOP,
		USER_ID		=> DIR::Misc::getStrIDFromNumID($user->id()),
		USER_NAME	=> Jcode->new($user->nickname(), 'ucs2')->utf8(),
		MODE_PASSWORD	=> DIR::Const::MODE_ACCOUNT_PASSWORD_MODIFY,
		MODE_NICKNAME	=> DIR::Const::MODE_ACCOUNT_NICKNAME_MODIFY,
		MODE_EMAIL		=> DIR::Const::MODE_ACCOUNT_ADD_EMAIL,
		MODE_LOGOUT		=> DIR::Const::MODE_ACCOUNT_LOGOUT,
		MODE_REMOVE		=> DIR::Const::MODE_ACCOUNT_REMOVE,
		MESSAGE			=> $self->getAlertMessage()));
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
# 	アカウントサインアップ完了画面を表示します。
# PARAM \% ユーザ マスター アカウント情報
sub putAccountSignupSucceeded{
	my $self = shift;
	my $user = shift;
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_ACCOUNT_SIGNUP,
		USER_ID			=> DIR::Misc::getStrIDFromNumID($user->id()),
		MODE_ACCOUNT	=> DIR::Const::MODE_ACCOUNT_TOP));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	アカウントログイン/サインアップ画面へのリダイレクトを出力します。
# PARAM NUM 次の移転先モード
sub putAccountCheckCookieRedirect{
	my $self = shift;
	my $mode = shift;
	$self->_redirect(sprintf('/?q=%d;qn=%d', DIR::Const::MODE_ACCOUNT_LOGIN_CHECKSESSION, $mode));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	アカウントトップ画面へのリダイレクトを出力します。
sub putAccountTopRedirect{
	my $self = shift;
	$self->putRedirect(DIR::Const::MODE_ACCOUNT_TOP);
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	パスワード入力画面を表示します。
sub putAccountPassword{
	my $self = shift;
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_ACCOUNT_PASSWORD,
		MODE_ACCOUNT	=> DIR::Const::MODE_ACCOUNT_TOP,
		MODE_PASSWORD	=> DIR::Const::MODE_ACCOUNT_PASSWORD_MODIFY,
		MESSAGE			=> $self->getAlertMessage()));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	ニックネーム入力画面を表示します。
# PARAM \% ユーザ マスター アカウント情報
sub putAccountNickname{
	my $self = shift;
	my $user = shift;
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_ACCOUNT_NICKNAME,
		MODE_NICKNAME	=> DIR::Const::MODE_ACCOUNT_NICKNAME_MODIFY,
		MODE_ACCOUNT	=> DIR::Const::MODE_ACCOUNT_TOP,
		NICKNAME		=> Jcode->new($user->nickname(), 'ucs2')->utf8(),
		MESSAGE			=> $self->getAlertMessage()));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	ニックネーム入力画面を表示します。
# PARAM \% ユーザ マスター アカウント情報
sub putAccountEMail{
	my $self = shift;
	my $user = shift;
	my $emails = [];
	my $i = 0;
	foreach my $email (@{$user->email()}){
		$i++;
		push(@$emails, {
			INDEX		=> $i,
			URI			=> $email->uri(),
			NOTIFY_DIR	=> $email->notifyService(),
			NOTIFY_ADS	=> $email->notifyAds(),
		});
	}
	$self->_put(DIR::Template::getHTT(DIR::Const::FILE_HTT_ACCOUNT_EMAIL,
		EMAILS			=> $emails,
		EMAIL_EXISTS	=> scalar(@$emails),
		MODE_EMAIL		=> DIR::Const::MODE_ACCOUNT_ADD_EMAIL,
		MODE_ACCOUNT	=> DIR::Const::MODE_ACCOUNT_TOP,
		MESSAGE			=> $self->getAlertMessage()));
}

1;

__END__
