#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ランキング定義のクラス。
#	1アカウントごとに1オブジェクトが割り当てられる。
package DIR::Ranking;
use 5.006;
use strict;
use warnings;
use utf8;
use DIR::Ranking::Limit;
use DIR::Ranking::Order;

$DIR::Ranking::VERSION =	# バージョン情報
	$DIR::Ranking::Limit::VERSION +
	$DIR::Ranking::Order::VERSION +
	0.01;

my %s_fields = (	# フィールド
	id			=> 0,							# ランキングID
	game_id		=> 0,							# ゲーム マスターID
	game		=> undef,						# ゲーム マスター情報
	caption		=> undef,						# ランキング名称
	view		=> [0, 0, 0, 0, 0, 0, 0, 0],	# スコア表示フラグ
	top_list	=> 0,							# ランキングTOPページにランキングリストを掲載するかどうか
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
