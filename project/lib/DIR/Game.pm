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
use DIR::Ranking;
use LWP::UserAgent;

$DIR::Game::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id				=> 0,									# ゲームID
	pub_id			=> 0,									# パブリッシャー ユーザ マスター アカウントID
	publisher		=> undef,								# パブリッシャー オブジェクト
	devcode			=> undef,								# 開発コード
	title			=> undef,								# タイトル
	validator		=> undef,								# 検証ツールURL
	reg_browser		=> 0,									# Webブラウザから登録可能かどうか
	score_caption	=> ['', '', '', '', '', '', '', ''],	# スコア名称一覧
	registed		=> time,								# 登録日時
	notes			=> undef,								# 備考
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC STATIC
#	データベース内からゲーム情報を新規作成します。
# RETURN @\% ゲーム情報の入ったオブジェクト一覧。
sub listNewAll{
	my @result = ();
	foreach my $info (DIR::DB->instance()->readGameAll()){
		my $obj = DIR::Game->newAllParams(
			id			=> $info->{ID},
			pub_id		=> $info->{PUB_ID},
			publisher	=> undef,
			devcode		=> $info->{DEVCODE},
			title		=> $info->{TITLE},
			validator	=> $info->{VALIDATOR},
			reg_browser	=> $info->{REG_BROWSER},
			registed	=> $info->{REGIST_TIME},
			notes		=> $info->{NOTES},
		);
		if(defined($obj)){ push(@result, $obj); }
	}
	return @result;
}

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
		DIR::Validate::isHttp($args{validator}) and ref($args{publisher}) eq 'DIR::User::Publisher'
	){
		my $obj = bless({%s_fields}, $class);
		$obj->{pub_id}		= $args{publisher}->id();
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
			$result = bless({%s_fields}, $class);
			$result->{id}			= $id;
			$result->{pub_id}		= $info->{PUB_ID};
			$result->{devcode}		= $info->{DEVCODE};
			$result->{title}		= $info->{TITLE};
			$result->{validator}	= $info->{VALIDATOR};
			$result->{reg_browser}	= $info->{REG_BROWSER};
			$result->{registed}		= $info->{REGIST_TIME};
			$result->{notes}		= $info->{NOTES};
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	パラメータを手動指定してゲーム情報を新規作成します。
# PARAM % フィールド全部
# RETURN \% ゲーム情報の入ったオブジェクト。
sub newAllParams{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(id pub_id devcode title validator registed)], 1, 1) and
		DIR::Validate::isExistParameter(\%args, [qw(reg_browser)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(publisher notes)])
	){ $result = bless({%args}, $class); }
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
		user_id					=> $self->publisherID(),
		dev_code				=> $self->devcode(),
		title					=> $self->title(),
		validator_uri			=> $self->validatorURI(),
		registable_on_browser	=> $self->isRegistableOnBrowser());
	if($self->isTemp()){
		my $id = $db->writeUserNew(%args);
		$result = (defined($id) and $id);
		if($result){ $self->{id} = $result; }
	}
	else{
		$result = $db->writeGameUpdate(
			score_name	=> $self->scoreCaption(),
			id			=> $self->id(),
			notes		=> $self->notes(),
			%args);
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトが同等のものかどうかを取得します。
# PARAM \% ゲーム情報オブジェクト
# RETURN BOOLEAN オブジェクトが同等である場合、真値。
sub isEquals{
	my $self = shift;
	my $expr = shift;
	my $result = ref($self) eq ref($expr);
	if($result){
		my $len = scalar(@{$self->scoreCaption()});
		if($len == scalar(@{$expr->scoreCaption()})){
			for(my $i = 7; $i >= 0; $i--){
				$result =
					($result and ($self->scoreCaption()->[$i] eq $expr->scoreCaption()->[$i]));
			}
			if($result){
				$result = (
					$self->id()						== $expr->id()						and
					$self->publisherID()			== $expr->publisherID()				and
					$self->devcode()				eq $expr->devcode()					and
					$self->title()					eq $expr->title()					and
					$self->validatorURI()			eq $expr->validatorURI()			and
					$self->isRegistableOnBrowser()	== $expr->isRegistableOnBrowser()	and
					$self->registed()				== $expr->registed()				and
					$self->notes()					eq $expr->notes());
			}
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	スコア認証コードが正しいかどうかを検出します。
# RETURN @ ステータスコード、スコア1～8。
sub validate{
	my $self = shift;
	my $password = shift;
	my @result = (-255, 0, 0, 0, 0, 0, 0, 0, 0);
	if(defined($password) and $password){
		my $lwp = LWP::UserAgent->new();
		$lwp->timeout(60);
		my $response = $lwp->request(
			HTTP::Request->new('GET', sprintf('%s?%s', $self->validatorURI(), $password)));
		if($response->is_success()){
			my $contents = $response->content();
			my $len;
			do{
				$len = length($contents);
				chomp($contents);
			}
			while($len > length($contents));
			if($contents =~ /^-?[0-9]+;/){
				my @head = split(/[; ]/, $contents);
				$result[0] = $head[0];
				if($head[0] and scalar(@head) == 9){ @result = @head; }
			}
		}
	}
	return @result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ランキング一覧を作成します。
# PARAM \% ランキング定義情報
# RETURN @ ランキング一覧。
sub ranking{
	my $self = shift;
	my $define = shift;
	my @result = ();
	my $strSQL = $define->sql();
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
#	パブリッシャー ユーザ マスター アカウントIDを取得します。
# RETURN \% パブリッシャー ユーザ マスター アカウントID。
sub publisherID{
	my $self = shift;
	return defined($self->{publisher}) ? $self->{publisher}->id() : $self->{pub_id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	パブリッシャー オブジェクトを取得します。
# RETURN \% パブリッシャー オブジェクト。
sub publisher{
	my $self = shift;
	unless(defined($self->{publisher})){
		$self->{publisher} = DIR::User::Publisher->newExist($self->publisherID());
	}
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
#	スコア名称一覧を取得します。
# RETURN \@ スコア名称一覧。
sub scoreCaption{
	my $self = shift;
	return $self->{score_caption};
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
