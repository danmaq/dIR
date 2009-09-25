#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ライバルのクラス。
#	1ライバルごとに1オブジェクトが割り当てられる。
package DIR::GameAccount::Rival;
use 5.006;
use strict;
use warnings;
use utf8;
use Jcode;
use DIR::GameAccount;
use DIR::DB;

$DIR::GameAccount::Rival::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	game_account_id	=> 0,		# ゲーム アカウントID
	game_account	=> undef,	# ゲーム アカウント情報
	rival_id		=> 0,		# ライバルのゲーム アカウントID
	rival			=> undef,	# ライバルのゲーム アカウント情報
	introduction	=> '',		# 紹介文
	registed		=> time,	# 登録日時(UNIX時間)
	inserted		=> 0,		# データベースに格納されているかどうか
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	ライバル情報を新規作成します。
# PARAM \%(game_account rival) ゲーム アカウント、ライバルのゲーム アカウント
# RETURN \% ライバル情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(_validateArgs(%args)){
		my $obj = bless({%s_fields}, $class);
		$obj->{game_account}	= $args{game_account};
		$obj->{rival}			= $args{rival};
		$obj->{game_account_id}	= $args{game_account}->id();
		$obj->{rival_id}		= $args{rival}->id();
		if($obj->commit()){ $result = $obj; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	スコアIDからスコア情報を新規作成します。
# PARAM \%(game_account rival) ゲーム アカウント、ライバルのゲーム アカウント
# RETURN \% スコア情報の入ったオブジェクト。
sub newExist{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(_validateArgs(%args)){
		my $info = DIR::DB->instance()->readRivalFromBothID(
			GACCOUNT_ID	=> $args{game_account}->id(),
			RIVAL_ID	=> $args{rival}->id());
		if(defined($info)){
			$result = bless({%s_fields}, $class);
			$result->{game_account}		= $args{game_account};
			$result->{rival}			= $args{rival};
			$result->{game_account_id}	= $args{game_account}->id();
			$result->{rival_id}			= $args{rival}->id();
			$result->{introduction}		= $info->{INTRODUCTION};
			$result->{registed}			= $info->{REGIST_TIME};
		}
	}
	return $result;
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトの変更をデータベースへ反映します。
# RETURN BOOLEAN 成功した場合、真値。
sub commit{
	my $self = shift;
	my $result = 0;
	my $db = DIR::DB->instance();
	if($self->{inserted}){
		$result = $db->writeRivalUpdate(
			INTRODUCTION	=> $self->introduction(),
			GACCOUNT_ID		=> $self->gameAccountID(),
			RIVAL_ID		=> $self->rivalID());
	}
	else{
		$result = $db->writeRivalInsert(
			INTRODUCTION	=> $self->introduction(),
			GACCOUNT_ID		=> $self->gameAccountID(),
			RIVAL_ID		=> $self->rivalID());
		$self->{inserted} = $result;
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトが同等のものかどうかを取得します。
# PARAM \% ライバル情報オブジェクト
# RETURN BOOLEAN オブジェクトが同等である場合、真値。
sub isEquals{
	my $self = shift;
	my $expr = shift;
	return (
		defined($expr)											and
		ref($expr)				eq 'DIR::GameAccount::Rival'	and
		$self->gameAccountID()	== $expr->gameAccountID()		and
		$self->rivalID()		== $expr->rivalID()				and
		$self->introduction()	eq $expr->introduction()		and
		$self->registed()		== $expr->registed()			and
		$self->{inserted}		== $expr->{inserted});
}

############################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム アカウントIDを取得します。
# RETURN \% ゲーム アカウントID。
sub gameAccountID{
	my $self = shift;
	return defined($self->{game_account}) ? $self->{game_account}->id() : $self->{game_account_id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム アカウント情報を取得します。
# RETURN \% ゲーム アカウント情報オブジェクト。
sub gameAccount{
	my $self = shift;
	if(defined($self->{game_account})){
		$self->{game_account} = DIR::GameAccount->newExist($self->{game_account_id});
	}
	return $self->{game_account};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ライバルのゲーム アカウントIDを取得します。
# RETURN \% ライバルのゲーム アカウントID。
sub rivalID{
	my $self = shift;
	return defined($self->{rival}) ? $self->{rival}->id() : $self->{rival_id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ライバルのゲーム アカウント情報を取得します。
# RETURN \% ライバルのゲーム アカウント情報オブジェクト。
sub rival{
	my $self = shift;
	if(defined($self->{rival})){ $self->{rival} = DIR::GameAccount->newExist($self->{rival_id}); }
	return $self->{rival};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	紹介文を取得/設定します。
# PARAM STRING (省略可)新しい紹介文
# RETURN STRING 紹介文。
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

#==========================================================
#==========================================================

#----------------------------------------------------------
# PRIVATE STATIC
#	引数の正当性を検査します。
# PARAM \%(game_account rival) ゲーム アカウント、ライバルのゲーム アカウント
# RETURN BOOLEAN 引数が正しい場合、真値。
sub _validateArgs{
	my %args = @_;
	return (
		DIR::Validate::isExistParameter(\%args, [qw(game_account rival)], 1, 1) and
		ref($args{game_account}) eq 'DIR::GameAccount' and
		ref($args{rival}) eq 'DIR::GameAccount' and
		$args{game_account}->id() and $args{rival}->id() and
		$args{game_account}->id() != $args{rival}->id());
}

1;

__END__
