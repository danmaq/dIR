#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	パスワード変更ページ表示スクリプト。
use 5.006;
use strict;
use warnings;
use lib qw(. ./lib);
use utf8;
use Switch;
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

# !!! XXX !!! : マジック文字列がひどい。なんとか汁


my $info = DIR::Input->instance()->getParamAccountPassword();
my $out = DIR::Output->instance();
my $user = DIR::User->newExistFromSession();
my $page = 'ACCOUNT_MODIFY_PASSWORD';
if(defined($info)){
	if(defined($user) and ref($info)){
		if($user->comparePassword($info->{password_old})){
			$user->password($info->{password_new});
			if($user->commit()){
				$page .= '_SUCCESS';
				$out->setAlertMessage('パスワード変更完了。');
				$out->putAccountCheckCookieRedirect(DIR::Const::MODE_ACCOUNT_TOP);
			}
			else{
				$page .= '_FAILED';
				$out->setAlertMessage('データベース格納時に予期しない不具合が発生したため、変更できません。');
				$out->putAccountPassword();
			}
		}
		else{
			$page .= '_FAILED';
			$out->setAlertMessage('旧パスワードが違います。');
			$out->putAccountPassword();
		}
	}
	else{
		$page .= '_FAILED';
		my $message = 'ログオンされていないか、予期しない不具合が発生したため、変更できません。';
		switch($info){
			case DIR::Input::Misc::PASSWORD_OVERRANGE	{ $message = '入力したパスワードは長すぎるか、または短すぎます。';	}
			case DIR::Input::Misc::PASSWORD_MISMATCH	{ $message = '再入力パスワードが間違っています。';					}
		}
		$out->setAlertMessage($message);
		$out->putAccountPassword();
	}
}
else{
	if(defined($user) and not $user->guest()){ $out->putAccountPassword(); }
	else{ $out->putAccountFailed(); }
}
DIR::Access->new(account => $user, page_name => $page);
DIR::DB->instance()->dispose();

1;

__END__
