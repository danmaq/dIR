#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ゲームスコアのクラス。
#	1アカウントごとに1オブジェクトが割り当てられる。
package DIR::Score;
use 5.006;
use strict;
use warnings;
use utf8;
use Jcode;

$DIR::Score::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id				=> 0,							# スコアID
	game_account	=> undef,						# ゲーム アカウント情報
	password		=> undef,						# スコア認証コード
	score			=> [0, 0, 0, 0, 0, 0, 0, 0],	# スコア
	injustice		=> undef,						# 不正フラグ
	withdraw		=> undef,						# 非公開フラグ
	registed		=> undef,						# 登録日時(UNIX時間)
	remote_addr		=> undef,						# リモートIPアドレス
	remote_host		=> undef,						# リモートホスト
	user_agent		=> undef,						# エージェント名
	notes			=> undef,						# 備考
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	ゲームスコアを新規作成します。
# PARAM \%(game_account password) ゲーム アカウント、スコア認証コード
# RETURN \% ゲームスコア情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(game_account password)], 1, 1) and
		ref($args{game_account}) eq 'DIR::GameAccount'
	){
		
	}
	return $result;
}

#==========================================================
#==========================================================

############################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	スコアIDを取得します。
# RETURN NUM スコアID。
sub id{
	my $self = shift;
	return $self->{id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	スコア認証コードを取得します。
# RETURN STRING スコア認証コード。
sub password{
	my $self = shift;
	return $self->{password};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	スコア一覧を取得します。
#	スコアは8個まで登録可能です。(それ以上挿入しても無視されます。)
# RETURN \@ スコア一覧。
sub score{
	my $self = shift;
	return $self->{score};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	このスコアは不正かどうかを取得/設定します。
# PARAM BOOLEAN (省略可)不正かどうか
# RETURN BOOLEAN 不正である場合、真値。
sub isInjustice{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{injustice} = $value ? 1 : 0; }
	return $self->{injustice};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	非公開にするかどうかを取得/設定します。
# PARAM BOOLEAN (省略可)非公開にするかどうか
# RETURN BOOLEAN 非公開である場合、真値。
sub isWithdraw{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{withdraw} = $value ? 1 : 0; }
	return $self->{withdraw};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	登録日時を取得します。
# RETURN NUM 登録日時(UNIX時間)。
sub registed{
	my $self = shift;
	return $self->{registed};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	リモートIPアドレスを取得します。
# RETURN STRING リモートIPアドレス。
sub remoteIP{
	my $self = shift;
	return $self->{remote_addr};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	リモートホストを取得します。
# RETURN STRING リモートホスト。
sub remoteHost{
	my $self = shift;
	return $self->{remote_host};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	エージェント名を取得します。
# RETURN STRING エージェント名。
sub userAgent{
	my $self = shift;
	return $self->{user_agent};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	備考を取得/設定します。
# PARAM STRING (省略可)新しい備考
# PARAM BOOLEAN (省略可)削除フラグ
# RETURN NUM 備考。存在しない場合、未定義値。
sub notes{
	my $self = shift;
	my $value = shift;
	my $del = shift;
	if(defined($value)){ $self->{notes} = $value; }
	if(defined($del) and $del){ $self->{notes} = undef; }
	return $self->{notes};
}

1;

__END__
