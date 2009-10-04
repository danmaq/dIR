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
use CGI qw(-compile);
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

#my $in = DIR::Input->instance();
my $out = DIR::Output->instance();
$out->putAccountLogin();
DIR::Access->new(account => undef, page_name => 'ACCOUNT_LOGIN');
DIR::DB->instance()->dispose();

1;

__END__