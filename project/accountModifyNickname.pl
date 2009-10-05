#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ニックネーム変更ページ表示スクリプト。
use 5.006;
use strict;
use warnings;
use lib qw(. ./lib);
use utf8;
use Switch;
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

# !!! XXX !!! : マジック文字列がひどい。なんとか汁

my $name = DIR::Input->instance()->getParamAccountNickname();
my $out = DIR::Output->instance();
my $user = DIR::User->newExistFromSession();
my $page = 'ACCOUNT_MODIFY_NICKNAME';
if(defined($user) and not $user->guest()){
	if(defined($name)){
		$user->nickname($name);
		if($user->commit()){
			$page .= '_SUCCESS';
			$out->setAlertMessage('ニックネーム変更完了。');
			$out->putAccountCheckCookieRedirect(DIR::Const::MODE_ACCOUNT_TOP);
		}
		else{
			$page .= '_FAILED';
			$out->setAlertMessage('データベース格納時に予期しない不具合が発生したため、変更できません。');
			$out->putNickname($user);
		}
	}
	else{ $out->putNickname($user); }
}
else{
	$page .= '_FAILED';
	$out->putAccountFailed();
}
DIR::Access->new(account => $user, page_name => $page);
DIR::DB->instance()->dispose();

1;

__END__
