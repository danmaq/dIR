#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ユーザ マスター アカウントTOPページ表示スクリプト。
use 5.006;
use strict;
use warnings;
use lib qw(. ./lib);
use utf8;
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

my $user = DIR::User->newExistFromSession();
my $result = (defined($user) and not $user->guest());
if(defined($user) and not $user->guest()){ $user->remove(); }
DIR::Output->instance()->putTopRedirect();
DIR::Access->new(account => $user, page_name => 'ACCOUNT_REMOVE');
DIR::DB->instance()->dispose();

1;

__END__
