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

$DIR::Score::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	ゲームスコアを新規作成します。
#	コミットされない限りは、プログラム終了と同時に削除されます。
# PARAM \%(passwd co_name head_name url mail commition) パスワード、団体名、代表者名、WebページURL、メールアドレス
# RETURN \% 定義情報の入ったオブジェクト。
sub new_temp{
	my $class = shift;
	my $args = shift;
	my $result = undef;
	return $result;
}

1;

__END__
