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

my $info = DIR::Input->instance()->getParamAccountEMail();
my $out = DIR::Output->instance();
my $user = DIR::User->newExistFromSession();
my $page = 'ACCOUNT_MODIFY_EMAIL';
if(defined($user) and not $user->guest()){
	if(defined($info) and ref($info)){
	}
	else{
	}
	$out->putNickname($user);
	# ! TODO : ここから作る
}
else{
	$page .= '_FAILED';
	$out->putAccountFailed();
}
DIR::Access->new(account => $user, page_name => $page);
DIR::DB->instance()->dispose();

1;

__END__
