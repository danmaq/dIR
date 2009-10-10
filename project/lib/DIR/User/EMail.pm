#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ユーザの電子メールアドレス管理クラス。
#	1メールアドレスごとに1オブジェクトが割り当てられる。
package DIR::User::EMail;
use 5.006;
use strict;
use warnings;
use utf8;
use Jcode;
use Digest::SHA1;
use DIR::DB;
use DIR::Misc;
use DIR::Validate;

$DIR::User::EMail::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id				=> 0,		# ユーザ マスター アカウントID
	email_url		=> undef,	# 電子メールアドレス
	validate_code	=> undef,	# メールアドレス認証コード
	notify_service	=> 0,		# dIRサービス通知フラグ
	notify_ads		=> 0,		# danmaq広告通知フラグ
	undeliverable	=> 0,		# 不達カウント
	registed		=> time,	# 登録日時(UNIX時間)
	inserted		=> 0,		# データベースに格納されているかどうか
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC STATIC
#	ユーザ マスター アカウントIDからメールアドレス情報オブジェクト一覧を生成します。
# PARAM \% ユーザのマスター アカウント オブジェクト
# PARAM BOOLEAN 認証済みメールアドレスのみ取得するかどうか
# RETURN @\% メールアドレス情報の入ったオブジェクト一覧。
sub listNewFromUID{
	my $user = shift;
	my $onlyValidated = shift;
	my @result = ();
	if(defined($user) and ref($user) eq 'DIR::User' and not $user->guest()){
		foreach my $info (DIR::DB->instance()->readEMailFromUID($user->id())){
			unless($onlyValidated and defined($info->{EMAIL_VALID})){
				my $obj = DIR::User::EMail->newAllParams(
					id				=> $user->id(),
					email_url		=> $info->{EMAIL},
					validate_code	=> $info->{EMAIL_VALID},
					notify_service	=> $info->{NOTIFY_SERVICE},
					notify_ads		=> $info->{NOTIFY_ADS},
					undeliverable	=> $info->{UNDELIVERABLE},
					registed		=> $info->{REGIST_TIME},
					inserted		=> 1);
				if(defined($obj)){ push(@result, $obj); }
			}
		}
	}
	return @result;
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	メールアドレス情報を新規作成します。
# PARAM %(user email service ads) ユーザのマスターアカウント、メールアドレス、サービス通知フラグ、広告通知フラグ
# RETURN \% メールアドレス情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(user email)], 1, 1) and
		DIR::Validate::isExistParameter(\%args, [qw(service ads)], 1) and
		ref($args{user}) eq 'DIR::User' and not $args{user}->guest() and
		DIR::Validate::isEMail($args{email}) and
		not defined(User::EMail->newExistFromURI($args{email}))
	){
		my $obj = bless({%s_fields}, $class);
		$obj->{id}				= $args{user}->id(),
		$obj->{validate_code}	= sprintf('%x', DIR::Misc::createRandomID(1)),
		$obj->{email_url}		= $args{email},
		$obj->{notify_service}	= $args{service};
		$obj->{notify_ads}		= $args{ads};
		if($obj->commit()){ $result = $obj; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	既にデータベースへ格納されているメールアドレスのオブジェクトを作成します。
# PARAM STRING 電子メールアドレス
# RETURN \% メールアドレス情報の入ったオブジェクト。存在しない場合、未定義値。
sub newExistFromURI{
	my $class = shift;
	my $email = shift;
	my $result = undef;
	if(DIR::Validate::isEMail($email)){
		my $info = DIR::DB->instance()->readEMailFromEMail($email);
		if(defined($info)){
			$result = bless({%s_fields}, $class);
			$result->{id}				= $info->{USER_ID};
			$result->{validate_code}	= $info->{EMAIL_VALID};
			$result->{notify_service}	= $info->{NOTIFY_SERVICE};
			$result->{notify_ads}		= $info->{NOTIFY_ADS};
			$result->{undeliverable}	= $info->{UNDELIVERABLE};
			$result->{registed}			= $info->{REGIST_TIME};
			$result->{inserted}			= 1;
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	パラメータを手動指定してメールアドレス情報を新規作成します。
# PARAM % フィールド全部
# RETURN \% メールアドレス情報の入ったオブジェクト。
sub newAllParams{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(id email_url registed inserted)], 1, 1) and
		DIR::Validate::isExistParameter(\%args, [qw(notify_service notify_ads undeliverable)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(validate_code)])
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
	my %params = (
		id		=> $self->userID(),
		email	=> $self->uri(),
		valid	=> $self->{validate_code},
		service	=> $self->notifyService(),
		ads		=> $self->notifyAds());
	if($self->isTemp()){
		$result = DIR::DB->instance()->writeEMailInsert(%params);
		if($result){ $self->{inserted} = 1; }
	}
	else{
		$result = DIR::DB->instance()->writeEMailUpdate(%params,
			undeliverable	=> $self->undeliverable());
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	情報をデータベースから削除します。
#	その際にオブジェクトも初期化されます。
# RETURN BOOLEAN 削除に成功した場合、真値。
sub remove{
	my $self = shift;
	my $result = DIR::DB->instance()->eraseEMail($self->uri());
	if($result){ %$self = %s_fields; }
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトが同等のものかどうかを取得します。
# PARAM \% 電子メール情報オブジェクト
# RETURN BOOLEAN オブジェクトが同等である場合、真値。
sub isEquals{
	my $self = shift;
	my $expr = shift;
	return (defined($expr)									and
		ref($expr)				eq 'DIR::EMail'				and
		$self->userID()			== $expr->userID()			and
		$self->uri()			eq $expr->uri()				and
		$self->notifyService()	== $expr->notifyService()	and
		$self->notifyAds()		== $expr->notifyAds()		and
		$self->undeliverable()	== $expr->undeliverable()	and
		$self->registed()		== $expr->registed()		and
		$self->{validate_code}	eq $expr->{validate_code}	and
		$self->{inserted}		== $expr->{inserted});
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	メールアドレスを認証します。
# PARAM STRING 認証コード
# RETURN BOOLEAN 認証に成功した場合、真値。
sub validate{
	my $self = shift;
	my $expr = shift;
	my $result = 0;
	if(defined($expr) and $self->{validate_code} eq $expr){
		$self->{validate_code} = undef;
		$result = $self->commit();
	}
	return $result;
}

############################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントIDを取得します。
# RETURN STRING ユーザ マスター アカウントID。
sub userID{
	my $self = shift;
	return $self->{id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	このオブジェクトが一時的なものかどうかを取得します。
# RETURN BOOL 一時的なものである場合、真値。
sub isTemp{
	my $self = shift;
	return ($self->userID() == 0 or not $self->{inserted});
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	このオブジェクトに登録されているメールアドレスが実在するかどうかを取得します。
# RETURN BOOL 実在する場合、真値。
sub isExists{
	my $self = shift;
	return (not $self->isTemp() and defined($self->{validate_code}));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	電子メールアドレスを取得します。
# RETURN STRING 電子メールアドレス。
sub uri{
	my $self = shift;
	return $self->{email_url};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	dIRサービス通知フラグを取得/設定します。
# RETURN BOOLEAN dIRサービス通知を希望する場合、真値。
sub notifyService{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{notify_service} = ($value ? 1 : 0); }
	return $self->{notify_service};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	danmaq広告通知フラグを取得/設定します。
# RETURN BOOLEAN danmaq広告通知を希望する場合、真値。
sub notifyAds{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{notify_ads} = ($value ? 1 : 0); }
	return $self->{notify_ads};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	電子メール不達カウントを取得します。
# RETURN NUM 不達カウント。
sub undeliverable{
	my $self = shift;
	return $self->{undeliverable};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	登録日時を取得します。
# RETURN NUM 登録日時(UNIX時間)。
sub registed{
	my $self = shift;
	return $self->{registed};
}

1;

__END__
