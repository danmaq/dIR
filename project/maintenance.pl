#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	メンテナンス中画面表示スクリプト。
use 5.006;
use strict;
use warnings;
use lib qw(. ./lib);
use utf8;
use DIR::Output;

use constant DIR_MAINTENANCE => 1;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

DIR::Output->instance()->putMaintenance();

1;

__END__
