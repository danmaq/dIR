#===============================================================================
#	Syllogismos Generator - "Socrates is Mortal"
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	標準入力等入力全般を司るクラス。
#	シングルトン。
package DIR::Input;
use 5.006;
use strict;
use warnings;
use utf8;
use base 'Class::Singleton';
use Jcode;
use CGI qw(-compile);
use CGI::Session;
use DIR::Validate;
use DIR::DB;

use constant COOKIE_ID		=> 'SESSIONID';
use constant COOKIE_EXPIRES	=> '+5m';
use constant SESSION_TABLE	=> 'DIR_SESSIONS';
use constant SESSION_KEY_ACCOUNT_ID	=> 'ACCOUNT_ID';

$DIR::Input::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	cgi => undef,		# CGIオブジェクト
	cookie => '',		# Cookie文字列
	session => undef,	# セッション オブジェクト
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	セッションをいったん閉じます。
#	プログラム終了前に必ず呼び出してください。
sub dispose{
	my $self = shift;
	if(defined($self->session())){
		$self->session()->flush();
		$self->{ session } = undef;
	}
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	リモート環境変数を取得します。
# RETURN \% リモート環境変数の一覧
sub getRemoteEnvironment{
	my $self = shift;
	my $cgi = $self->cgi();
	return {
		addr	=> ($cgi->remote_addr() or '127.0.0.1'),
		host	=> ($cgi->remote_host() or 'localhost'),
		agent	=> ($cgi->user_agent() or ''),
		referer	=> $cgi->referer(),
	};
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	動作モードを取得します。
# RETURN STRING 動作モード文字列
sub getMode{
	my $self = shift;
	return $self->cgi()->param('mode') or '';
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	アクセスログ収集のためのページ情報を取得します。
# RETURN % ページ情報一覧
sub getPageInfo{
	my $self = shift;
	my %result = (name => undef, number => undef);
	my $vars = $self->cgi()->Vars();
	if(DIR::Validate::isExistParameter($vars, [qw(name number)], 1)){
		$result{ name }		= $vars->{ name };
		$result{ number }	= length($vars->{ number }) == 0 ? undef : $vars->{ number };
	}
	return %result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	CGIオブジェクトを取得します。
# RETURN \% CGIオブジェクト
sub cgi{
	my $self = shift;
	return $self->{ cgi };
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	Cookie文字列を取得します。
# RETURN STRING Cookie文字列
sub cookie{
	my $self = shift;
	return $self->{ cookie };
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	セッション オブジェクトを取得します。
# RETURN \% セッション オブジェクト
sub session{
	my $self = shift;
	return $self->{ session };
}

#==========================================================
#==========================================================

#------------------------------------------------------------------------------
# PRIVATE STATIC
# 	インスタンスを作成します。
# RETURN \% オブジェクト
sub _trim{
	my $expr = shift;
	$expr =~ s/^\s+//g;
	$expr =~ s/\s+$//g;
	return $expr;
}

#------------------------------------------------------------------------------
# PRIVATE NEW
# 	インスタンスを作成します。
#	インスタンス取得時に1度だけ自動的に呼び出されます。
# RETURN \% オブジェクト
sub _new_instance{
	my $self = bless({ %s_fields }, shift);
	binmode(STDIN, ':bytes');
	my $cgi = CGI->new();
	my $session = new CGI::Session('driver:MySQL',
		($cgi->cookie(COOKIE_ID) or undef),
		{ TableName => SESSION_TABLE, Handle => DIR::DB->instance()->dbi() });
	$self->{ cookie } = $cgi->cookie(
		-name => COOKIE_ID,
		-value => $session->id(),
		-expires => COOKIE_EXPIRES);
	$self->{ cgi } = $cgi;
	$self->{ session } = $session;
	return $self;
}

1;

__END__