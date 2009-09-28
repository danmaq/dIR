#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	クライアント振り分け・表示などのCGI。
use 5.006;
use strict;
use warnings;
use utf8;
use lib qw(. ./lib);
use Switch;
use DIR::Const;
use DIR::Input;

#	require 'maintenance.pl';

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

unless(exists(&DIR_MAINTENANCE)){
	my $mode = DIR::Input->instance()->getMode();
	switch($mode){
		case DIR::Const::MODE_RANK_TOP	{ require 'ranktop.pl';	}
		else							{ require 'top.pl';		}
	}
}

__END__
