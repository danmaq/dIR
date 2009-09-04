#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ゲームパブリッシャーのクラス。
#	1アカウントごとに1インスタンスが割り当てられる。
package DIR::Publisher;
use 5.006;
use strict;
use warnings;
use utf8;
use Jcode;

$DIR::Publisher::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	ID			=> 0,	# パブリッシャーID
	PASSWD		=> '',	# パスワード
	CO_NAME		=> '',	# 会社名・団体名
	HEAD_NAME	=> '',	# 代表者名
	URL			=> 0,	# WebページURL
	MAIL		=> '',	# メールアドレス
	COMMISSION	=> '',	# 権限レベル
	REGIST_TIME	=> 0,	# 登録日時
	NOTES		=> '',	# 備考
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	ゲームパブリッシャーを新規作成します。
#	コミットされない限りは、プログラム終了と同時に削除されます。
# PARAM \%(passwd co_name head_name url mail commition) パスワード、団体名、代表者名、WebページURL、メールアドレス
# RETURN \% 定義情報の入ったインスタンス。
sub new_temp{
	my $class = shift;
	my $args = shift;
	my $result = undef;
	return $result;
}

1;

__END__
