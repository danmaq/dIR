#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ユーザ マスター アカウントのクラス。
#	1アカウントごとに1インスタンスが割り当てられる。
package DIR::User;
use 5.006;
use strict;
use warnings;
use utf8;
use Jcode;
use Digest::SHA1;
use DIR::Validate;
use DIR::User::EMail;

$DIR::User::VERSION =	# バージョン情報
	$DIR::User::EMail::VERSION +
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

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	ユーザ マスター アカウントのオブジェクトを作成します。
# PARAM STRING パスワード(4～40字以内)
# RETURN \% ゲストユーザ情報の入ったインスタンス。
sub new{
	my $class = shift;
	my $password = shift;
	my $result = undef;
	if(DIR::Validate::isLengthInRange($password, 4, 40)){
		my $sha1 = Digest::SHA1->new();
		$result = bless({%s_fields}, $class);
		$sha1->add($password);
		$result->{password} = $sha1->b64digest();
		$result->{login_count} = 1;
		$result->commit();
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	ゲストユーザのオブジェクトを作成します。
#	このオブジェクトはデータベースへ格納できません。
# RETURN \% ゲストユーザ情報の入ったインスタンス。
sub new_guest{ return bless({%s_fields}, shift); }

#==========================================================
#==========================================================

sub commit{
	my $self = shift;
	# TODO : 作りかけ
}

############################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントIDを取得します。
# RETURN STRING ユーザ マスター アカウントID。
sub id{
	my $self = shift;
	return $self->{id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	このインスタンスがゲストユーザかどうかを取得します。
# RETURN BOOL ゲストユーザである場合、真値。
sub guest{
	my $self = shift;
	my $id = $self->id();
	return (not defined($id)) or $id == 0;
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
	return $self->{login_count};
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
#	備考を取得します。
# PARAM STRING (省略可)新しい備考
# RETURN NUM 備考。存在しない場合、未定義値。
sub notes{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{notes} = $value; }
	return $self->{notes};
}

1;

__END__
