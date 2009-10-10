#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	電子メール追加・変更・削除ページ表示スクリプト。
use 5.006;
use strict;
use warnings;
use lib qw(. ./lib);
use utf8;
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

# !!! XXX !!! : マジック文字列がひどい。なんとか汁

my $out = DIR::Output->instance();
my $user = DIR::User->newExistFromSession();
my $page = 'ACCOUNT_MODIFY_EMAIL';
if(defined($user) and not $user->guest()){
	my $info = DIR::Input->instance()->getParamAccountEMail();
	if(defined($info)){
		if(ref($info)){
			$out->setAlertMessage(
				$user->modifyEMail(@$info) ? 'メールアドレス設定および変更が完了しました。' :
				'他のユーザが使用しているメールアドレスか、またはデータベース通信エラーが発生しました。'
			);
		}
		else{ $out->setAlertMessage('メールアドレスが不正です。'); }
	}
	$out->putAccountEMail($user);
}
else{
	$page .= '_FAILED';
	$out->putAccountFailed();
}
DIR::Access->new(account => $user, page_name => $page);
DIR::DB->instance()->dispose();

1;

__END__
