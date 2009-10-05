#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	セッション確認ページ表示スクリプト。
use 5.006;
use strict;
use warnings;
use lib qw(. ./lib);
use utf8;
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

my $nextMode = DIR::Input->instance()->getParamRedirectNextMode();
my $out = DIR::Output->instance();
my $user = DIR::User->newExistFromSession();
my $page = (defined($user) ? 1 : 0);
if($page){ $out->putRedirect($nextMode); }
else{ $out->putAccountFailed(); }
DIR::Access->new(account => $user, page_name => 'ACCOUNT_LOGIN_CHECK_SESSION', page_number => $page);
DIR::DB->instance()->dispose();

1;

__END__
