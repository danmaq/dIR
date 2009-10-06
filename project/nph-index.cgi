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
#	use CGI::Carp 'fatalsToBrowser';
use Switch;
use DIR;

#	use CGI qw(-nph);
#	print CGI->new()->header();

#	$DIR::Output::Misc::RETRY_AFTER = 3600 * 24;
#	require 'maintenance.pl';

require 'ini.pl' unless(exists(&DIR_INI));	# 設定ファイル

unless(exists(&DIR_MAINTENANCE)){
	my $mode = DIR::Input->instance()->getMode();
	switch($mode){
		case DIR::Const::MODE_RANK_TOP						{ require 'ranktop.pl';						}
		case DIR::Const::MODE_RANK_DESCRIPTION				{ require 'rankDescription.pl';				}
		case DIR::Const::MODE_ACCOUNT_TOP					{ require 'accountTop.pl';					}
		case DIR::Const::MODE_ACCOUNT_LOGIN					{ require 'accountLogin.pl';				}
		case DIR::Const::MODE_ACCOUNT_LOGIN_CHECKSESSION	{ require 'accountLoginCheckSession.pl';	}
		case DIR::Const::MODE_ACCOUNT_LOGOUT				{ require 'accountLogout.pl';				}
		case DIR::Const::MODE_ACCOUNT_SIGNUP				{ require 'accountSignup.pl';				}
		case DIR::Const::MODE_ACCOUNT_SIGNUP_SUCCEEDED		{ require 'accountSignupSucceeded.pl';		}
		case DIR::Const::MODE_ACCOUNT_PASSWORD_MODIFY		{ require 'accountModifyPassword.pl';		}
		case DIR::Const::MODE_ACCOUNT_NICKNAME_MODIFY		{ require 'accountModifyNickname.pl';		}
		case DIR::Const::MODE_ACCOUNT_ADD_EMAIL				{ require 'maintenance.pl';					}
		case DIR::Const::MODE_ACCOUNT_REMOVE				{ require 'accountRemove.pl';				}
		case ''												{ require 'top.pl';							}
		else												{ require 'maintenance.pl';					}
	}
}

__END__
