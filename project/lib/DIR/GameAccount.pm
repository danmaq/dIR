#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ゲームアカウントのクラス。
#	1アカウントごとに1オブジェクトが割り当てられる。
package DIR::GameAccount;
use 5.006;
use strict;
use warnings;
use utf8;
use Digest::SHA1;
use DIR::DB;
use DIR::Game;
use DIR::Misc;
use DIR::User;
use DIR::Validate;

$DIR::GameAccount::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id				=> 0,		# ゲーム アカウントID
	user			=> undef,	# ユーザ マスター アカウント情報オブジェクト
	game			=> undef,	# ゲーム マスター情報オブジェクト
	password		=> undef,	# パスワード(SHA1でハッシュ化)
	nickname		=> undef,	# ニックネーム
	introduction	=> '',		# 自己紹介
	registed		=> time,	# 登録日時(UNIX時間)
	last_renew		=> time,	# 最終更新日時(UNIX時間)
	last_login		=> time,	# 最終ログイン日時(UNIX時間)
	login_count		=> 0,		# ログイン回数
	notes			=> undef,	# 備考
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	ゲーム アカウントを新規作成します。
# PARAM %(user gamme password nickname)
#	ユーザ マスター アカウント、ゲーム マスター、パスワード、(省略可)ニックネーム
# RETURN \% ゲーム アカウント情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(user game password)], 1, 1) and
		ref($args{user}) =~ /DIR::User/ and ref($args{game}) eq 'DIR::Game' and
		DIR::Validate::isLengthInRange($args{password}, 4, 40) and
		not ($args{game}->isTemp() or $args{game}->guest())
	){
		my $obj = DIR::GameAccount->newExistFromGameAndUser(
			game => $args{game}, user => $args{user});
		if(defined($obj)){ $result = $obj; }
		else{
			$obj = bless({%s_fields}, $class);
			$obj->{user} = $args{user};
			$obj->{game} = $args{game};
			$obj->password($args{password});
			if(exists($args{nickname})){ $obj->nickname($args{nickname}); }
			if($obj->commit()){ $result = $obj; }
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	既にデータベースへ格納されているゲーム アカウントのオブジェクトを作成します。
# (1) PARAM NUM 格納用ゲーム アカウントID
# (2) PARAM STRING 表示用ゲーム アカウントID
# RETURN \% ゲーム アカウント情報の入ったオブジェクト。存在しない場合、未定義値。
sub newExistFromID{
	my $class = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		if(DIR::Misc::isIDFormat($id)){ $id = DIR::Misc::getNumIDFromStrID($id); }
		my $info = DIR::DB->instance()->readGameAccountFromID($id);
		if(defined($info)){
			my $user = DIR::User->newExist($info->{USER_ID});
			my $game = DIR::Game->newExist($info->{GAME_ID});
			if(defined($user) and defined($game)){
				$result = bless({%s_fields}, $class);
				$result->{id}			= $id;
				$result->{user}			= $user;
				$result->{game}			= $game;
				$result->{password}		= $info->{PASSWD};
				$result->{nickname}		= $info->{NICKNAME};
				$result->{introduction}	= $info->{INTRODUCTION};
				$result->{registed}		= $info->{REGIST_TIME};
				$result->{last_renew}	= $info->{RENEW_TIME};
				$result->{last_login}	= $info->{LOGIN_TIME};
				$result->{login_count}	= $info->{LOGIN_COUNT};
				$result->{notes}		= $info->{NOTES};
			}
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	既にデータベースへ格納されているゲーム アカウントのオブジェクトを作成します。
# PARAM %(user game) ユーザ マスター アカウント情報、ゲーム マスター情報
# RETURN \% ゲーム アカウント情報の入ったオブジェクト。存在しない場合、未定義値。
sub newExistFromGameAndUser{
	my $self = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(user game)], 1, 1) and
		ref($args{user}) =~ /DIR::User/ and ref($args{game}) eq 'DIR::Game'
	){
		my $id = DIR::DB->instance()->readGameAccountIDFromGameAndUser(
			game_id	=> $args{game}->id(),
			user_id	=> $args{user}->id(),
		);
		if(defined($id) and $id){ $result = DIR::GameAccount->newExistFromID($id); }
	}
	return $result;
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	このアカウントにログインします。
# PARAM STRING パスワード(4～40字以内)
# RETURN BOOLEAN 成功した場合、真値。
sub login{
	my $self = shift;
	my $result = 0;
	my $password = shift;
	if($self->id() and DIR::Validate::isLengthInRange($password, 4, 40)){
		my $sha1 = Digest::SHA1->new();
		$sha1->add($password);
		$result = ($self->password() eq $sha1->b64digest());
		if($result){
			$result = DIR::DB->instance()->writeGameAccountLogin(
				id		=> $self->id(),
				user_id	=> $self->user()->id(),
				game_id	=> $self->game()->id(),
			);
			if($result){
				$result->{last_login}	= time;
				$result->{login_count}	+= 1;
			}
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトの変更をデータベースへ反映します。
# RETURN BOOLEAN 成功した場合、真値。
sub commit{
	my $self = shift;
	my $result = 0;
	my $db = DIR::DB->instance();
	my %params = (
		user_id		=> $self->user()->id(),
		game_id		=> $self->game()->id(),
		password	=> $self->password());
	if($self->id()){
		$result = $db->writeGameAccountRenew(
			id				=> $self->id(),
			nickame			=> $self->nickname(),
			introduction	=> $self->introduction(),
			notes			=> $self->notes(),
			%params);
	}
	else{
		my $id;
		my $i = 0;
		do{ $id = DIR::Misc::createRandomID($i++ < 5); }
		while(defined(DIR::GameAccount->newExistFromID($id)));
		$self->{id} = $id;
		if(defined($self->nickname())){ $self->nickname(DIR::Misc::getStrIDFromNumID($id)); }
		$result = $db->writeGameAccountNew(
			id				=> $id,
			nickame			=> $self->nickname(),
			introduction	=> $self->introduction(),
			%params);
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトが同等のものかどうかを取得します。
# PARAM \% バッチ レポート オブジェクト
# RETURN BOOLEAN オブジェクトが同等である場合、真値。
sub isEquals{
	my $self = shift;
	my $expr = shift;
	return (
		defined($expr)										and
		ref($expr)				eq 'DIR::GameAccount'		and
		$self->game()->isEquals($expr->game())				and
		$self->user()->isEquals($expr->user())				and
		$self->id()				== $expr->id()				and
		$self->password()		eq $expr->password()		and
		$self->nickname()		eq $expr->nickname()		and
		$self->introduction()	eq $expr->introduction()	and
		$self->registed()		== $expr->registed()		and
		$self->lastRenew()		== $expr->lastRenew()		and
		$self->lastLogin()		== $expr->lastLogin()		and
		$self->loginCount()		== $expr->loginCount()		and
		$self->notes()			eq $expr->notes());
}

############################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントIDを取得します。
# RETURN NUM ユーザ マスター アカウントID。
sub id{
	my $self = shift;
	return $self->{id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム マスターを取得します。
# RETURN NUM ゲーム マスター情報オブジェクト。
sub game{
	my $self = shift;
	return $self->{game};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントを取得します。
# RETURN NUM ユーザ マスター アカウント情報オブジェクト。
sub user{
	my $self = shift;
	return $self->{user};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	SHA1でハッシュ化されたパスワードを取得します。
# RETURN STRING SHA1でハッシュ化されたパスワード。
sub password{
	my $self = shift;
	return $self->{password};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ニックネームを取得/設定します。
# PARAM STRING (省略可)新しいニックネーム
# RETURN STRING ニックネーム。
sub nickname{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{nickname} = $value; }
	return $self->{nickname};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	自己紹介を取得/設定します。
# PARAM STRING (省略可)新しい自己紹介
# RETURN STRING 自己紹介。
sub introduction{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{introduction} = $value; }
	return $self->{introduction};
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
#	最終更新日時を取得します。
# RETURN NUM 最終更新日時(UNIX時間)。
sub lastRenew{
	my $self = shift;
	return $self->{last_renew};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	最終ログイン日時を取得します。
# RETURN NUM 最終ログイン日時(UNIX時間)。
sub lastLogin{
	my $self = shift;
	return $self->{last_login};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ログイン回数を取得します。
# RETURN NUM ログイン回数。
sub loginCount{
	my $self = shift;
	return $self->{login_count};
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
