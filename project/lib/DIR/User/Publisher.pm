#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ゲームパブリッシャーのクラス。
#	1アカウントごとに1オブジェクトが割り当てられる。
package DIR::User::Publisher;
use 5.006;
use strict;
use warnings;
use utf8;
use base qw(DIR::User);
use DIR::Validate;
use DIR::DB;

$DIR::User::Publisher::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	co_name		=> '',		# 会社名・団体名
	head_name	=> '',		# 代表者名
	uri			=> '',		# WebページURL
	commision	=> 0,		# 権限レベル
	registed	=> time,	# 登録日時(UNIX時間)
	notes		=> undef,	# 備考
	inserted	=> 0,		# データベースに格納されているかどうか
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	ゲームパブリッシャーを新規作成します。
# PARAM %(user_id co_name head_name uri) ユーザ マスター アカウントID、団体名、代表者名、URL
# RETURN \% 定義情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(user_id co_name head_name uri)], 1)){
		my $super = DIR::User::Publisher->newExistFromUID($args{user_id});
		if(defined($super) and not $super->guest()){
			if($super->isPublisher()){ $result = $super; }
			else{
				my $obj = bless($super, $class);
				$obj->{publisher}				= {%s_fields};
				$obj->{publisher}->{co_name}	= $args{co_name};
				$obj->{publisher}->{head_name}	= $args{head_name};
				$obj->{publisher}->{uri}		= $args{uri};
				if($obj->commit()){ $result = $obj; }
			}
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	既にデータベースへ格納されているユーザのオブジェクトを作成します。
# (1) PARAM NUM 格納用ユーザ マスター アカウントID
# (2) PARAM STRING 表示用ユーザ マスター アカウントID
# RETURN \% ユーザ情報の入ったオブジェクト。存在しない場合、未定義値。
sub newExistFromUID{
	my $class = shift;
	my $uid = shift;
	my $result = undef;
	if(defined($uid)){
		my $super = DIR::User->newExist($uid);
		if(defined($super)){
			my $info = DIR::DB->instance()->readPublisherFromUID($super->id());
			if(defined($info)){
				$result = bless($super, $class);
				$result->{publisher}				= {%s_fields};
				$result->{publisher}->{co_name}		= $info->{CO_NAME};
				$result->{publisher}->{head_name}	= $info->{HEAD_NAME};
				$result->{publisher}->{uri}			= $info->{URL};
				$result->{publisher}->{commision}	= $info->{COMMISSION};
				$result->{publisher}->{registed}	= $info->{REGIST_TIME};
				$result->{publisher}->{notes}		= $info->{NOTES};
			}
			else{ $result = $super; }
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
		DIR::Validate::isExistParameter(\%args, [qw(co_name head_name uri registed inserted)], 1, 1) and
		DIR::Validate::isExistParameter(\%args, [qw(commision)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(notes)])
	){
		my $super = DIR::User->newAllParams(%args);
		$result = bless($super, $class);
		$super->{co_name}	= $args{co_name};
		$super->{head_name}	= $args{head_name};
		$super->{uri}		= $args{uri};
		$super->{commision}	= $args{commision};
		$super->{registed}	= $args{registed};
		$super->{notes}		= $args{notes};
		$super->{inserted}	= $args{inserted};
	}
	return $result;
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトの変更をデータベースへ反映します。
# PARAM BOOLEAN (省略可=TRUE)ユーザ マスター アカウント情報も同時にコミットするかどうか
# RETURN BOOLEAN 成功した場合、真値。
sub commit;		# OVERRIDE

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトが同等のものかどうかを取得します。
# PARAM \% パブリッシャー情報オブジェクト
# RETURN BOOLEAN オブジェクトが同等である場合、真値。
sub isEquals;	# OVERRIDE

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	パブリッシャー権限を持つかどうかを取得します。
# RETURN BOOL パブリッシャー権限を持つ場合、真値。
sub isPublisher{ return 1; }

#----------------------------------------------------------
# PUBLIC INSTANCE
#	会社名・団体名を取得/設定します。
# PARAM STRING (省略可)新しい会社名・団体名
# RETURN STRING 会社名・団体名。
sub coName{
	my $self = shift;
	my $value = shift;
	if(defined($value) and length($value)){ $self->{publisher}->{co_name} = $value; }
	return $self->{publisher}->{co_name};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	代表者名を取得/設定します。
# PARAM STRING (省略可)新しい代表者名
# RETURN STRING 代表者名。
sub headName{
	my $self = shift;
	my $value = shift;
	if(defined($value) and length($value)){ $self->{publisher}->{head_name} = $value; }
	return $self->{publisher}->{head_name};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	WebページURLを取得/設定します。
# PARAM STRING (省略可)新しいWebページURL
# RETURN STRING WebページURL。
sub uri{
	my $self = shift;
	my $value = shift;
	if(defined($value) and length($value)){ $self->{publisher}->{uri} = $value; }
	return $self->{publisher}->{uri};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	権限レベルを取得/設定します。
# PARAM STRING (省略可)新しい権限レベル
# RETURN STRING 権限レベル。
sub commision{
	my $self = shift;
	my $value = shift;
	if(defined($value) and length($value)){ $self->{publisher}->{uri} = $value; }
	return $self->{publisher}->{uri};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	登録日時を取得します。
# RETURN NUM 登録日時(UNIX時間)。
sub registed{
	my $self = shift;
	return $self->{publisher}->{registed};
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
	if(defined($value)){ $self->{publisher}->{notes} = $value };
	if(defined($del) and $del){ $self->{publisher}->{notes} = undef; }
	return $self->{publisher}->{notes};
}

#==========================================================
#==========================================================

{	# commit オーバーライド ブロック。
	my $fnSuper = \&DIR::User::commit;
	my $fnSub = sub{
		my $self = shift;
		my $super = shift;
		my $result = 0;
		my $db = DIR::DB->instance();
		my %args = (
			id			=> $self->id(),
			co_name		=> $self->coName(),
			head_name	=> $self->headName(),
			uri			=> $self->uri(),
		);
		if($self->{publisher}->{inserted}){
			$result = $db->writePublisherUpdate(%args,
				commision => $self->commision());
		}
		else{
			$result = $db->writePublisherInsert(%args);
			if($result){ $self->{publisher}->{inserted} = 1; }
		}
		return ($result and (!(defined($super) and $super) or $fnSuper->($self)));
	};
	{
		no warnings qw(redefine);
		*DIR::User::Publisher::commit = $fnSub;
	}
}

{	# isEquals オーバーライド ブロック。
	my $fnSuper = \&DIR::User::isEquals;
	my $fnSub = sub{
		my $self = shift;
		my $expr = shift;
		return ($fnSuper->($self)										and
			ref($expr)						eq 'DIR::User::Publisher'	and
			$self->coName()					eq $expr->coName()			and
			$self->headName()				eq $expr->headName()		and
			$self->uri()					eq $expr->uri()				and
			$self->commision()				== $expr->commision()		and
			$self->registed()				== $expr->registed()		and
			$self->notes()					eq $expr->notes()			and
			$self->{publisher}->{inserted}	== $expr->{publisher}->{inserted});
	};
	{
		no warnings qw(redefine);
		*DIR::User::Publisher::isEquals = $fnSub;
	}
}

1;

__END__
