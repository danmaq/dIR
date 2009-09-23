#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ゲームクラス。
#	1ゲームごとに1オブジェクトが割り当てられる。
package DIR::Game;
use 5.006;
use strict;
use warnings;
use utf8;
use DIR::DB;
use DIR::User;
use LWP::UserAgent;

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
# RETURN \% ゲーム情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(publisher devcode title validator reg_browser)], 1) and
		ref($args{publisher}) eq 'DIR::User::Publisher'
	){
		my $obj = bless({%s_fields}, $class);
		$obj->{publisher}	= $args{publisher};
		$obj->{devcode}		= $args{devcode};
		$obj->{title}		= $args{title};
		$obj->{validator}	= $args{validator};
		$obj->{reg_browser}	= $args{reg_browser};
		if($obj->commit()){ $result = $obj; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	ゲームIDからゲーム情報を新規作成します。
# PARAM NUM ゲームID
# RETURN \% ゲーム情報の入ったオブジェクト。
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

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトの変更をデータベースへ反映します。
# RETURN BOOLEAN 成功した場合、真値。
sub commit{
	my $self = shift;
	my $result = 0;
	my $db = DIR::DB->instance();
	my %args = (
		user_id					=> $self->publisher()->id(),
		dev_code				=> $self->devcode(),
		title					=> $self->title(),
		validator_uri			=> $self->validatorURI(),
		registable_on_browser	=> $self->isRegistableOnBrowser());
	if($self->isTemp()){
		$result = $db->writeUserNew(%args);
		if(defined($result) and $result){ $self->{id} = $result; }
	}
	else{
		$result = $db->writeGameUpdate(
			id		=> $self->id(),
			notes	=> $self->notes(),
			%args);
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
		$self->id()						== $expr->id()						and
		$self->devcode()				eq $expr->devcode()					and
		$self->title()					eq $expr->title()					and
		$self->validatorURI()			eq $expr->validatorURI()			and
		$self->isRegistableOnBrowser()	== $expr->isRegistableOnBrowser()	and
		$self->registed()				== $expr->registed()				and
		$self->notes()					eq $expr->notes()					and
		$self->publisher()->isEquals($expr->publisher()));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	スコア認証コードが正しいかどうかを検出します。
# RETURN @ ステータスコード、スコア1～8。
sub validate{
	my $self = shift;
	my $password = shift;
	@result = [-255, 0, 0, 0, 0, 0, 0, 0, 0];
	if(defined($password) and $password){
		my $lwp = LWP::UserAgent->new();
		$lwp->timeout(60);
		my $response = $lwp->request(
			HTTP::Request->new('GET', sprintf('%s?%s', $self->validatorURI(), $password)));
		if($response->is_success()){
			
		}
		# ! TODO : 書きかけよ
	}
	return @result;
}

############################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲームIDを取得します。
# RETURN NUM ゲームID。
sub id{
	my $self = shift;
	return $self->{id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	このオブジェクトが一時的なものかどうかを取得します。
# RETURN BOOL 一時的なものである場合、真値。
sub isTemp{
	my $self = shift;
	return (not defined($self->id()));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	パブリッシャー オブジェクトを取得します。
# RETURN \% パブリッシャー オブジェクト。
sub publisher{
	my $self = shift;
	return $self->{publisher};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	開発コードを取得/設定します。
# PARAM STRING (省略可)新しい開発コード
# RETURN STRING 開発コード。
sub devcode{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{devcode} = $value; }
	return $self->{devcode};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	タイトルを取得/設定します。
# PARAM STRING (省略可)新しいタイトル
# RETURN STRING タイトル。
sub title{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{title} = $value; }
	return $self->{title};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	検証ツールURLを取得/設定します。
# PARAM STRING (省略可)新しい検証ツールURL
# RETURN STRING 検証ツールURL。
sub validatorURI{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{validator} = $value; }
	return $self->{validator};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	Webブラウザから登録可能かどうかを取得/設定します。
# PARAM BOOLEAN (省略可)Webブラウザから登録可能かどうか
# RETURN BOOLEAN Webブラウザから登録可能である場合、真値。
sub isRegistableOnBrowser{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{reg_browser} = $value ? 1 : 0; }
	return $self->{reg_browser};
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
