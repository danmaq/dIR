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

$DIR::Input::Misc::VERSION = 0.01;	# バージョン情報

@DIR::Input::Misc::ISA = qw(Exporter);
@DIR::Input::Misc::EXPORT = qw(
	getParamRankTop
	getParamRankDescription
	getParamRedirectNextMode
	getParamAccountLogin
	getParamAccountSignup
	getParamAccountPassword
	getParamAccountNickname
);

#==========================================================
#==========================================================

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
	my $id = $self->cgi()->param('id');
	my $password = $self->cgi()->param('pwd');
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
	my $passwordOld = $self->cgi()->param('old');
	my $passwordNew = $self->cgi()->param('new');
	my $passwordNewRe = $self->cgi()->param('re');
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
