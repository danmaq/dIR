#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	アクセスログ情報のクラス。
#	1アカウントごとに1オブジェクトが割り当てられる。
package DIR::Access;
use 5.006;
use strict;
use warnings;
use utf8;
use DIR::Input;
use DIR::User;

$DIR::Access::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id			=> 0,		# アクセスログID
	user_id		=> 0,		# ユーザ マスター アカウントID
	user		=> undef,	# ユーザ マスター アカウント オブジェクト
	page_name	=> undef,	# ページ名称
	page_number	=> 0,		# ページ番号
	referer		=> undef,	# リファラ
	create_time	=> time,	# 作成日時
	remote_addr	=> undef,	# リモートIPアドレス
	remote_host	=> undef,	# リモートホスト
	user_agent	=> undef,	# エージェント名
	notes		=> undef,	# 備考
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	アクセスログ情報を新規作成します。
# PARAM \%(user page_name page_number)
#	(省略可)ユーザ マスター アカウント、ページ名称、(省略可)ページ番号
# RETURN \% アクセスログ情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(DIR::Validate::isExistParameter(\%args, [qw(page_name)], 1)){
		my $env = DIR::Input->instance()->getRemoteEnvironment();
		my $obj = bless({%s_fields}, $class);
		unless(exists($args{user}) and ref($args{user}) =~ /^DIR::User/ and not $args{user}->guest()){
			$obj->{user_id}	= $args{user}->id();
			$obj->{user}	= $args{user};
		}
		$obj->{page_name}	= $args{page_name};
		$obj->{page_number}	=
			((exists($args{page_number}) and defined($args{page_number})) ? $args{page_number} : 0);
		$obj->{referer}		= $env->{referer};
		$obj->{remote_addr}	= $env->{addr};
		$obj->{remote_host}	= $env->{host};
		$obj->{user_agent}	= $env->{agent};
		if($obj->commit()){ $result = $obj; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	既にデータベースへ格納されているアクセスログのオブジェクトを作成します。
# PARAM NUM アクセスログID
# RETURN \% アクセスログ情報の入ったオブジェクト。存在しない場合、未定義値。
sub newExist{
	my $class = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $info = DIR::DB->instance()->readAccessFromID($id);
		if(defined($info)){
			$result = bless({%s_fields}, $class);
			$result->{id}			= $id;
			$result->{user_id}		= $info->{USER_ID};
			$result->{page_name}	= $info->{PAGE_NAME};
			$result->{page_number}	= $info->{PAGE_NUMBER};
			$result->{referer}		= $info->{REFERER};
			$result->{create_time}	= $info->{CREATE_TIME};
			$result->{remote_addr}	= $info->{REMOTE_ADDR};
			$result->{remote_host}	= $info->{REMOTE_HOST};
			$result->{user_agent}	= $info->{USER_AGENT};
			$result->{notes}		= $info->{NOTES};
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
	if($self->id()){ $result = $db->writeAccessUpdate(id => $self->id(), notes => $self->notes()); }
	else{
		my $id = $db->writeAccessInsert(
			user_id		=> $self->userID(),
			page_name	=> $self->pageName(),
			page_number	=> $self->pageNumber(),
			referer		=> $self->referer(),
			remote_addr	=> $self->remoteIP(),
			remote_host	=> $self->remoteHost(),
			user_agent	=> $self->userAgent());
		$result = (defined($id) and $id);
		if($result){ $self->{id} = $id; }
	}
	return $result;
}

############################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	アクセスログIDを取得します。
# RETURN NUM アクセスログID。
sub id{
	my $self = shift;
	return $self->{id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントIDを取得します。
# RETURN NUM ユーザ マスター アカウントID。
sub userID{
	my $self = shift;
	return $self->{user_id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ユーザ マスター アカウントを取得します。
# RETURN NUM ユーザ マスター アカウント オブジェクト。
sub user{
	my $self = shift;
	if(defined($self->{user})){
		$self->{user} = DIR::User::Publisher->newExistFromUID($self->userID());
	}
	return $self->{user};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ページ名称を取得します。
# RETURN STRING ページ名称。
sub pageName{
	my $self = shift;
	return $self->{page_name};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ページ番号を取得します。
# RETURN NUM ページ番号。
sub pageNumber{
	my $self = shift;
	return $self->{page_number};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	作成日時を取得します。
# RETURN NUM 作成日時(UNIX時間)。
sub created{
	my $self = shift;
	return $self->{create_time};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	リファラを取得します。
# RETURN STRING リファラ。
sub referer{
	my $self = shift;
	return $self->{referer};
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
