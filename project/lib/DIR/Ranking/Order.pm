#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ランキング並替条件アイテムのクラス。
#	1アイテムごとに1オブジェクトが割り当てられる。
package DIR::Ranking::Order;
use 5.006;
use strict;
use warnings;
use utf8;

$DIR::Ranking::Order::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id				=> 0,	# アイテムID
	score_column	=> 0,	# ゲーム アカウントID
	border			=> 0,	# ゲーム アカウント情報
	less			=> 1,	# スコア認証コード
	more			=> 1,	# スコア
	gap				=> 0,	# 不正フラグ
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	スコアを新規作成します。
# PARAM \%(game_account password) ゲーム アカウント、スコア認証コード
# RETURN \% スコア情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(game caption)], 1, 1) and
		ref($args{game}) eq 'DIR::Game'
	){
		my $obj = bless({%s_fields}, $class);
		$obj->{game_id}	= $args{game}->id();
		$obj->{game}	= $args{game};
		$obj->{caption}	= $args{caption};
		if($obj->commit()){ $result = $obj; }
	}
	return $result;
}

sub commit{ 0; }

1;

__END__
