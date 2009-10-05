#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	サインアップ処理スクリプト。
use 5.006;
use strict;
use warnings;
use lib qw(. ./lib);
use utf8;
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

my $out = DIR::Output->instance();
my $password = DIR::Input->instance()->getParamAccountSignup();
my $user = undef;
my $result = 0;
if(defined($password)){
	$user = DIR::User->new($password);
	$result = (defined($user) and not $user->guest() and $user->login($password));
	if($result){ $out->putAccountCheckCookieRedirect(DIR::Const::MODE_ACCOUNT_SIGNUP_SUCCEEDED); }
}
unless($result){ $out->putAccountFailed(); }
DIR::Access->new(account => $user, page_name => 'ACCOUNT_SIGNUP');
DIR::DB->instance()->dispose();

1;

__END__
