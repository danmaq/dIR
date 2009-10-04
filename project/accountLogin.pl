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

my $in = DIR::Input->instance();
my $out = DIR::Output->instance();
my $info = $in->getParamAccountLogin();
my $result = 0;
if(defined($info)){
	my $user = undef;
	if(defined($info->{user_id})){ $user = DIR::User->newExist($info->{user_id}); }
	if(defined($info->{email})){
		my $email = DIR::User::EMail->newExistFromURI($info->{email});
		if(defined($email)){ $user = DIR::User->newExist($email->userID()); }
	}
	$result = (defined($user) and $user->login($info->{password}));
	if($result){ $out->putAccountCheckCookieRedirect(); }
}
unless($result){ $out->putAccountFailed(); }
DIR::Access->new(account => undef, page_name => 'ACCOUNT_LOGIN', page_number => $result);
DIR::DB->instance()->dispose();

1;

__END__
