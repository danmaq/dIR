#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ゲームクラス。
package DIR::Game;
use 5.006;
use strict;
use warnings;
use utf8;
use DIR::DB;
use DIR::User;

$DIR::Game::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id			=> 0,		# ゲームID
	publisher	=> undef,	# パブリッシャー オブジェクト
	devcode		=> undef,	# 開発コード
	title		=> undef,	# タイトル
	validator	=> undef,	# 検証ツールURL
	reg_browser	=> 0,		# Webブラウザから登録可能かどうか
	registed	=> time,	# 登録日時
	notes		=> undef,	# 備考
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	ゲーム情報を新規作成します。
# PARAM %(publisher devcode title validator reg_browser)
#	パブリッシャー オブジェクト、開発コード、タイトル、検証ツールURL、Webブラウザから登録可能かどうか
# RETURN \% ゲーム情報の入ったインスタンス。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	ゲームIDからゲーム情報を新規作成します。
# PARAM NUM ゲームID
# RETURN \% ゲーム情報の入ったインスタンス。
sub newExistFromID{
	my $class = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $info = DIR::DB->instance()->readGameFromID($id);
		if(defined($info)){
			my $user = DIR::User->newExist($info->{PUB_ID});
			if(defined($user)){
				$result = bless({%s_fields}, $class);
				$result->{id}			= $id;
				$result->{publisher}	= $user;
				$result->{devcode}		= $info->{DEVCODE};
				$result->{title}		= $info->{TITLE};
				$result->{validator}	= $info->{VALIDATOR};
				$result->{reg_browser}	= $info->{REG_BROWSER};
				$result->{registed}		= $info->{REGIST_TIME};
				$result->{notes}		= $info->{NOTES};
			}
		}
	}
	return $result;
}

#==========================================================
#==========================================================

1;

__END__
