#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ユーザ マスター アカウント サインアップ完了ページ表示スクリプト。
use 5.006;
use strict;
use warnings;
use lib qw(. ./lib);
use utf8;
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

my $out = DIR::Output->instance();
my $user = DIR::User->newExistFromSession();
if(defined($user) and not $user->guest()){ $out->putAccountSignupSucceeded($user); }
else{ $out->putAccountFailed(); }
DIR::Access->new(account => $user, page_name => 'ACCOUNT_SIGNUP_SUCCEEDED');
DIR::DB->instance()->dispose();

1;

__END__
