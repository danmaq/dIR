#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	既存カテゴリに該当しない雑多なWeb入力を司るクラス。
# ! NOTE : このクラスは、実質DIR::Inputの一部として機能します。
package DIR::Input::Misc;
use 5.006;
use strict;
use warnings;
use utf8;
use Exporter;
use Jcode;
use DIR::Misc;
use DIR::Validate;

use constant PASSWORD_OVERRANGE		=> 0;
use constant PASSWORD_MISMATCH		=> 1;

use constant EMAIL_IGNORE			=> 0;

$DIR::Input::Misc::VERSION = 0.01;	# バージョン情報

@DIR::Input::Misc::ISA = qw(Exporter);
@DIR::Input::Misc::EXPORT = qw(
	getMode
	getParamRankTop
	getParamRankDescription
	getParamRedirectNextMode
	getParamAccountLogin
	getParamAccountSignup
	getParamAccountPassword
	getParamAccountNickname
	getParamAccountEMail
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	動作モードを取得します。
# RETURN STRING 動作モード文字列
sub getMode{
	my $self = shift;
	my $result = $self->cgi()->param('q');
	unless(defined($result)){ $result = ''; }
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	ランキングTOPページのクエリ情報を取得します。
# RETURN NUM ゲームID
sub getParamRankTop{
	my $self = shift;
	return _getGameMasterID($self);
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	ランキング詳細ページのクエリ情報を取得します。
# RETURN NUM ランキング定義ID
sub getParamRankDescription{
	my $self = shift;
	return _getRankingDefineID($self);
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	次にリダイレクトするモード番号を取得します。
# RETURN NUM モード番号
sub getParamRedirectNextMode{
	my $self = shift;
	return $self->getNumber('qn');
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	ログインページのクエリ情報を取得します。
# RETURN NUM ランキング定義ID
sub getParamAccountLogin{
	my $self = shift;
	my $result = undef;
	my $cgi = $self->cgi();
	my $id = $cgi->param('id');
	my $password = $cgi->param('pwd');
	my $uid = (DIR::Misc::isIDFormat($id) ? $id : undef);
	my $email = (DIR::Validate::isEMail($id) ? $id : undef);
	if(DIR::Validate::isLengthInRange($password, 4, 40) and (defined($uid) or defined($email))){
		$result = {
			user_id		=> $uid,
			email		=> $email,
			password	=> $password};
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	ログインページのクエリ情報を取得します。
# RETURN NUM ランキング定義ID
sub getParamAccountSignup{
	my $self = shift;
	my $result = undef;
	my $password = $self->cgi()->param('pwd');
	if(DIR::Validate::isLengthInRange($password, 4, 40)){ $result = $password; }
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	パスワード変更ページのクエリ情報を取得します。
# RETURN NUM ランキング定義ID
sub getParamAccountPassword{
	my $self = shift;
	my $result = undef;
	my $cgi = $self->cgi();
	my $passwordOld = $cgi->param('old');
	my $passwordNew = $cgi->param('new');
	my $passwordNewRe = $cgi->param('re');
	if(defined($passwordOld) and defined($passwordNew) and defined($passwordNewRe)){
		if(
			DIR::Validate::isLengthInRange($passwordOld, 4, 40) and
			DIR::Validate::isLengthInRange($passwordNew, 4, 40) and
			DIR::Validate::isLengthInRange($passwordNewRe, 4, 40)
		){
			if($passwordNew eq $passwordNewRe){
				$result = {
					password_old => $passwordOld,
					password_new => $passwordNew
				};
			}
			else{ $result = PASSWORD_MISMATCH; }
		}
		else{ $result = PASSWORD_OVERRANGE; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	ニックネーム変更ページのクエリ情報を取得します。
# RETURN STRING 新しいニックネーム。
sub getParamAccountNickname{
	my $self = shift;
	my $result = undef;
	my $name = $self->cgi()->param('name');
	if(DIR::Validate::isLengthInRange($name, 1, 255)){
		$result = Jcode->new($name, 'utf8')->ucs2();
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
# 	電子メール設定・変更・削除ページのクエリ情報を取得します。
# RETURN \@ 電子メール情報。
sub getParamAccountEMail{
	my $self = shift;
	my $result = undef;
	my $cgi = $self->cgi();
	my $eoq = 0;
	my $i = 0;
	my @modlist = ();
	do{
		my $uri		= $cgi->param(sprintf('uri_%s',		$i));
		my $ndir	= $cgi->param(sprintf('ndir_%s',	$i));
		my $nads	= $cgi->param(sprintf('nads_%s',	$i));
		$eoq = (not (
			defined($uri)	and
			defined($ndir)	and
			defined($nads)));
		$i++;
		unless($eoq){
			unless($uri){ next; }
			$eoq = (not DIR::Validate::isEMail($uri));
			if($eoq){ $result = EMAIL_IGNORE; }
			push(@modlist, {
				uri			=> $uri,
				notify_dir	=> $ndir,
				notify_ads	=> $nads,
			});
		}
	}
	until($eoq);
	if(not defined($result) and scalar(@modlist)){ $result = [@modlist]; }
	return $result;
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PRIVATE STATIC
# 	ゲーム マスターIDを取得します。
# RETURN NUM ゲーム マスターID
sub _getGameMasterID{
	my $self = shift;
	return $self->getNumber('g');
}

#----------------------------------------------------------
# PRIVATE STATIC
# 	ランキング定義IDを取得します。
# RETURN NUM ゲームID
sub _getRankingDefineID{
	my $self = shift;
	return $self->getNumber('r');
}

1;

__END__
