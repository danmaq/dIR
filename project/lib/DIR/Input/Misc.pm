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
use DIR::Misc;
use DIR::Validate;

$DIR::Input::Misc::VERSION = 0.01;	# バージョン情報

@DIR::Input::Misc::ISA = qw(Exporter);
@DIR::Input::Misc::EXPORT = qw(
	getParamRankTop
	getParamRankDescription
	getParamRedirectNextMode
	getParamAccountLogin
	getParamAccountSignup
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
	my $passwordLength = length($password);
	if(
		defined($password) and $passwordLength > 4 and $passwordLength < 40 and
		(defined($uid) or defined($email))
	){
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
	my $passwordLength = length($password);
	if(defined($password) and $passwordLength > 4 and $passwordLength < 40){ $result = $password; }
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
