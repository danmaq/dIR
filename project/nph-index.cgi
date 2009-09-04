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
use CGI qw(-nph);
use DIR;

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

my $cgi = CGI->new();
print $cgi->header(-content_type => 'text/plain');
print DIR::versionShort();
print "\n";

__END__
