#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ユーザ マスター アカウントのクラス。
#	1アカウントごとに1オブジェクトが割り当てられる。
package DIR::User;
use 5.006;
use strict;
use warnings;
use utf8;
use Jcode;
use Digest::SHA1;
use DIR::DB;
use DIR::Misc;
use DIR::Validate;
use DIR::User::EMail;
use DIR::User::Publisher;

$DIR::User::VERSION =	# バージョン情報
	$DIR::User::EMail::VERSION +
	$DIR::User::Publisher::VERSION +
	0.01;

my %s_fields = (	# フィールド
	id				=> 0,										# ユーザ マスター アカウントID
	password		=> undef,									# パスワード(SHA1でハッシュ化)
	email			=> [],										# メール アカウント オブジェクト
	nickname		=> Jcode->new('ゲスト', 'utf8')->ucs2(),	# ニックネーム
	introduction	=> Jcode->new('非会員', 'utf8')->ucs2(),	# 自己紹介
	registed		=> time,									# 登録日時(UNIX時間)
	last_renew		=> time,									# 最終更新日時(UNIX時間)
	last_login		=> time,									# 最終ログイン日時(UNIX時間)
	login_count		=> 0,										# ログイン回数
	notes			=> undef,									# 備考
);

# ! TODO : メールアドレス追加/削除処理

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	ユーザ マスター アカウントのオブジェクトを作成します。
# PARAM STRING パスワード(4～40字以内)
# RETURN \% ゲストユーザ情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my $password = shift;
	my $result = undef;
	if(DIR::Validate::isLengthInRange($password, 4, 40)){
		my $obj = DIR::User->new_guest();
		$obj->password($password);
		$obj->{login_count} = 1;
		if($obj->commit()){ $result = $obj; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	ゲストユーザのオブジェクトを作成します。
#	このオブジェクトはデータベースへ格納できません。
# RETURN \% ゲストユーザ情報の入ったオブジェクト。
sub new_guest{ return bless({%s_fields}, shift); }

#----------------------------------------------------------
# PUBLIC NEW
#	既にデータベースへ格納されているユーザのオブジェクトを作成します。
# (1) PARAM NUM 格納用ユーザ マスター アカウントID
# (2) PARAM STRING 表示用ユーザ マスター アカウントID
# RETURN \% ユーザ情報の入ったオブジェクト。存在しない場合、未定義値。
sub newExist{
	my $class = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id)){
		$result = DIR::User->new_guest();
		if($id){
			if(DIR::Misc::isIDFormat($id)){ $id = DIR::Misc::getNumIDFromStrID($id); }
			my $info = DIR::DB->instance()->readUserFromID($id);
			if(defined($info)){
				$result->{id}			= $id;
				$result->{password}		= $info->{PASSWD};
				$result->{nickname}		= $info->{NICKNAME};
				$result->{introduction}	= $info->{INTRODUCTION};
				$result->{registed}		= $info->{REGIST_TIME};
				$result->{last_renew}	= $info->{RENEW_TIME};
				$result->{last_login}	= $info->{LOGIN_TIME};
				$result->{login_count}	= $info->{LOGIN_COUNT};
				$result->{notes}		= $info->{NOTES};
				$result->{email}		= [DIR::User::EMail::createObjFromUID($result)];
			}
		}
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
	if(!$self->temp() and DIR::Validate::isLengthInRange($password, 4, 40)){
		my $sha1 = Digest::SHA1->new();
		$sha1->add($password);
		$result = ($self->password() eq $sha1->b64digest());
		if($result){
			$result = DIR::DB->instance()->writeUserLogin($self->id());
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
	if($self->temp()){
		my $id;
		my $i = 0;
		do{ $id = DIR::Misc::createRandomID($i++ < 5); }
		while(defined(DIR::User->newExist($id)));
		$self->{id}			= $id;
		$self->{nickname}	= DIR::Misc::getStrIDFromNumID($id);
		$result = $db->writeUserNew(
			id				=> $id,
			password		=> $self->password(),
			nickame			=> $self->nickname(),
			introduction	=> $self->introduction());
		if($result){
			$self->{introduction}	= '';
			$result->{registed}		= time;
			$result->{last_renew}	= time;
			$result->{last_login}	= time;
		}
	}
	else{
		$result = $db->writeUserRenew(
			id				=> $self->id(),
			password		=> $self->password(),
			nickame			=> $self->nickname(),
			introduction	=> $self->introduction(),
			notes			=> $self->notes());
		if($result){ $result->{last_renew} = time; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトが同等のものかどうかを取得します。
# PARAM \% ユーザ マスター アカウント情報オブジェクト
# RETURN BOOLEAN オブジェクトが同等である場合、真値。
sub isEquals{
	my $self = shift;
	my $expr = shift;
	my $result = 0;
	if(defined($expr) and ref($expr) =~ /^DIR::User/){
		my @selfMail = $self->email();
		my @exprMail = $expr->email();
		my $selfLenth = scalar(@selfMail);
		my $exprLenth = scalar(@exprMail);
		if($selfLenth == $exprLenth){
			my $bEMailEquals = 1;
			for(my $i = $selfLenth - 1; $i >= 0; $i--){
				$bEMailEquals = ($bEMailEquals and $selfMail[$i]->isEquals($exprMail[$i]));
			}
			$result = ($bEMailEquals								and
				$self->id()				== $expr->id()				and
				$self->isPublisher()	== $expr->isPublisher()		and
				$self->password()		eq $expr->password()		and
				$self->nickname()		eq $expr->nickname()		and
				$self->introduction()	eq $expr->introduction()	and
				$self->registed()		== $expr->registed()		and
				$self->lastRenew()		== $expr->lastRenew()		and
				$self->lastLogin()		== $expr->lastLogin()		and
				$self->loginCount()		== $expr->loginCount()		and
				$self->notes()			eq $expr->notes());
		}
	}
	
	return $result;
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
#	このオブジェクトが一時的なものかどうかを取得します。
# RETURN BOOL 一時的なものである場合、真値。
sub temp{
	my $self = shift;
	return (not defined($self->id()));
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	このオブジェクトがゲストユーザかどうかを取得します。
# RETURN BOOL ゲストユーザである場合、真値。
sub guest{
	my $self = shift;
	return $self->temp() or $self->id() == 0;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	パブリッシャー権限を持つかどうかを取得します。
# RETURN BOOL パブリッシャー権限を持つ場合、真値。
sub isPublisher{ return 0; }

#----------------------------------------------------------
# PUBLIC INSTANCE
#	SHA1でハッシュ化されたパスワードを取得/設定します。
# PARAM STRING (省略可)新しいパスワード
# RETURN STRING SHA1でハッシュ化されたパスワード。
sub password{
	my $self = shift;
	my $value = shift;
	if(defined($value)){
		my $sha1 = Digest::SHA1->new();
		$sha1->add($value);
		$self->{password} = $sha1->b64digest();
	}
	return $self->{password};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	メールアドレス一覧を取得します。
# RETURN @ メールアドレス一覧。
sub email{
	my $self = shift;
	return $self->{email};
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
