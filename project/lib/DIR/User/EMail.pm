#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ユーザのクラス。
#	1アカウントごとに1インスタンスが割り当てられる。
package DIR::User::EMail;
use 5.006;
use strict;
use warnings;
use utf8;
use Jcode;
use Digest::SHA1;
use DIR::Validate;

$DIR::User::EMail::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id				=> 0,
	email_url		=> undef,
	validate_code	=> undef,
	notify_service	=> 0,
	notify_ads		=> 0,
	undeliverable	=> 0,
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	ユーザを新規作成します。
#	コミットされない限りは、プログラム終了と同時に削除されます。
# PARAM \DIR::User ユーザのマスターアカウント
# RETURN \% 定義情報の入ったインスタンス。
sub new_temp{
	my $class = shift;
	my $result = undef;
	return $result;
}

1;

__END__
