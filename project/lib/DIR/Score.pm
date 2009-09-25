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
use DIR::GameAccount;

$DIR::Score::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id				=> 0,							# スコアID
	game_account_id	=> 0,							# ゲーム アカウントID
	game_account	=> undef,						# ゲーム アカウント情報
	password		=> undef,						# スコア認証コード
	score			=> [0, 0, 0, 0, 0, 0, 0, 0],	# スコア
	injustice		=> 0,							# 不正フラグ
	withdraw		=> 0,							# 非公開フラグ
	registed		=> time,						# 登録日時(UNIX時間)
	remote_addr		=> undef,						# リモートIPアドレス
	remote_host		=> undef,						# リモートホスト
	user_agent		=> undef,						# エージェント名
	notes			=> undef,						# 備考
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	スコアを新規作成します。
# PARAM \%(game_account password) ゲーム アカウント、スコア認証コード
# RETURN \% スコア情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(game_account password)], 1, 1) and
		ref($args{game_account}) eq 'DIR::GameAccount'
	){
		my @score = $args{game_account}->game()->validate($args{password});
		if(scalar(@score) == 9 and $score[0] >= 0){
			shift(@score);
			my $env = DIR::Input->instance()->getRemoteEnvironment();
			my $obj = bless({%s_fields}, $class);
			$obj->{game_account_id}	= $args{game_account}->id();
			$obj->{game_account}	= $args{game_account};
			$obj->{socre}			= [@score];
			$obj->{password}		= $args{password};
			$obj->{remote_addr}		= $env->{addr};
			$obj->{remote_host}		= $env->{host};
			$obj->{user_agent}		= $env->{agent};
			if($obj->commit()){ $result = $obj; }
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	スコアIDからスコア情報を新規作成します。
# PARAM NUM スコアID
# RETURN \% スコア情報の入ったオブジェクト。
sub newExist{
	my $class = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $info = DIR::DB->instance()->readScoreFromID($id);
		if(defined($info)){
			$result = bless({%s_fields}, $class);
			$result->{id}				= $id;
			$result->{game_account_id}	= $info->{GACCOUNT_ID};
			$result->{password}			= $info->{PASSWD};
			$result->{score}			= $info->{SCORE};
			$result->{injustice}		= $info->{INJUSTICE};
			$result->{withdraw}			= $info->{WITHDRAW};
			$result->{registed}			= $info->{REGIST_TIME};
			$result->{remote_addr}		= $info->{REMOTE_ADDR};
			$result->{remote_host}		= $info->{REMOTE_HOST};
			$result->{user_agent}		= $info->{USER_AGENT};
			$result->{notes}			= $info->{NOTES};
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
	if($self->id()){
		$result = $db->writeScoreUpdate(
			ID			=> $self->id(),
			INJUSTICE	=> $self->isInjustice(),
			WITHDRAW	=> $self->isWithdraw(),
			NOTES		=> $self->notes());
	}
	else{
		my $id = $db->writeScoreInsert(
			GACCOUNT_ID	=> $self->gameAccountID(),
			PASSWD		=> $self->password(),
			SCORE		=> $self->score(),
			REMOTE_ADDR	=> $self->remoteIP(),
			REMOTE_HOST	=> $self->remoteHost(),
			USER_AGENT	=> $self->userAgent());
		$result = (defined($id) and $id);
		if($result){ $self->{id} = $id; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトが同等のものかどうかを取得します。
# PARAM \% スコア情報オブジェクト
# RETURN BOOLEAN オブジェクトが同等である場合、真値。
sub isEquals{
	my $self = shift;
	my $expr = shift;
	my $result = 0;
	if(defined($expr) and ref($expr) eq 'DIR::Score'){
		my $selfScore = $self->score();
		my $exprScore = $expr->score();
		my $len = scalar(@$selfScore);
		my $equalScore = ($len == scalar(@$exprScore));
		if($equalScore){
			for(my $i = $len - 1; $i >= 0; $i--){
				$equalScore = ($equalScore and $selfScore->[$i] == $exprScore->[$i]);
			}
		}
		$result = ($equalScore									and
			$self->id()				== $expr->id()				and
			$self->gameAccountID()	== $expr->gameAccountID()	and
			$self->password()		eq $expr->password()		and
			$self->isInjustice()	== $expr->isInjustice()		and
			$self->isWithdraw()		== $expr->isWithdraw()		and
			$self->registed()		== $expr->registed()		and
			$self->remoteIP()		eq $expr->remoteIP()		and
			$self->remoteHost()		eq $expr->remoteHost()		and
			$self->userAgent()		eq $expr->userAgent()		and
			$self->notes()			eq $expr->notes());
	}
	return $result;
}

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
