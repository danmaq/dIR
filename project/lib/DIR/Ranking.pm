#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ランキング定義のクラス。
#	1定義ごとに1オブジェクトが割り当てられる。
package DIR::Ranking;
use 5.006;
use strict;
use warnings;
use utf8;
use DIR::DB;
use DIR::Validate;
use DIR::Ranking::Limit;
use DIR::Ranking::Order;

$DIR::Ranking::COLUMN_NAME = [qw(
	SCORE0 SCORE1 SCORE2 SCORE3
	SCORE4 SCORE5 SCORE6 SCORE7
)];	# データベースのカラム名

$DIR::Ranking::VERSION =	# バージョン情報
	$DIR::Ranking::Limit::VERSION +
	$DIR::Ranking::Order::VERSION +
	0.01;

my %s_fields = (	# フィールド
	id			=> 0,							# ランキングID
	game_id		=> 0,							# ゲーム マスターID
	game		=> undef,						# ゲーム マスター情報
	caption		=> undef,						# ランキング名称
	view		=> [0, 0, 0, 0, 0, 0, 0, 0],	# スコア表示フラグ一覧
	limit		=> [],							# 絞込アイテム一覧
	order		=> [],							# 並替アイテム一覧
	top_list	=> 0,							# ランキングTOPページにランキングリストを掲載するかどうか
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC STATIC
#	ゲーム マスター情報から絞込条件ランキング定義一覧を作成します。
# PARAM \% ゲーム マスター情報
# RETURN @\% ランキング定義の入ったオブジェクト一覧。
sub listNewFromGame{
	my @result = ();
	my $game = shift;
	if(defined($game) and ref($game) eq 'DIR::Game'){
		foreach my $info (DIR::DB->instance()->readRankingFromGameID($game->id())){
			my $obj = DIR::Ranking->newAllParams(
				id				=> $info->{ID},
				game_id			=> $game->id(),
				game			=> $game,
				caption			=> $info->{CAPTION},
				view			=> $info->{VIEW},
				limit			=> [],
				order			=> [],
				top_list		=> $info->{TOP_LIST});
			if(defined($obj)){
				$obj->{limit} = [DIR::Ranking::Limit::listNewFromRanking($obj)];
				$obj->{order} = [DIR::Ranking::Order::listNewFromRanking($obj)];
				push(@result, $obj);
			}
		}
	}
	return @result;
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	ランキング定義を新規作成します。
# PARAM \%(game caption) ゲーム マスター情報、ランキング名称
# RETURN \% ランキング定義情報の入ったオブジェクト。
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

#----------------------------------------------------------
# PUBLIC NEW
#	ランキング定義IDからランキング定義情報を新規作成します。
# PARAM NUM ランキング定義ID
# RETURN \% ランキング定義情報の入ったオブジェクト。
sub newExist{
	my $class = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $info = DIR::DB->instance()->readRankingFromID($id);
		if(defined($info)){
			$result = bless({%s_fields}, $class);
			$result->{id}			= $id;
			$result->{game_id}		= $info->{GAME_ID};
			$result->{caption}		= $info->{CAPTION};
			$result->{view}			= $info->{VIEW};
			$result->{limit}		= [DIR::Ranking::Limit::listNewFromRanking($result)];
			$result->{order}		= [DIR::Ranking::Order::listNewFromRanking($result)];
			$result->{top_list}		= $info->{TOP_LIST};
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	パラメータを手動指定してランキング定義情報を新規作成します。
# PARAM % フィールド全部
# RETURN \% ランキング定義情報の入ったオブジェクト。
sub newAllParams{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(id game_id caption view limit order)], 1, 1) and
		DIR::Validate::isExistParameter(\%args, [qw(top_list)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(game)]) and
		ref($args{view}) eq 'ARRAY' and ref($args{limit}) eq 'ARRAY' and ref($args{order}) eq 'ARRAY'
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
	my $db = DIR::DB->instance();
	my %args = (
		GAME_ID	=> $self->publisherID(),
		CAPTION	=> $self->devcode());
	if($self->id()){
		$result = $db->writeRankingUpdate(
			ID			=> $self->id(),
			VIEW		=> $self->isViewList(),
			TOP_LIST	=> $self->isViewListInTop(),
			%args);
	}
	else{
		my $id = $db->writeRankingInsert(%args);
		$result = (defined($id) and $id);
		if($result){ $self->{id} = $result; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトが同等のものかどうかを取得します。
# PARAM \% ゲーム情報オブジェクト
# RETURN BOOLEAN オブジェクトが同等である場合、真値。
sub isEquals{
	my $self = shift;
	my $expr = shift;
	my $result = ref($self) eq ref($expr);
	if($result){
		my @selfArrays = ($self->isViewList(), $self->limitList(), $self->orderList());
		my @exprArrays = ($expr->isViewList(), $expr->limitList(), $expr->orderList());
		for(my $i = scalar(@selfArrays) - 1; $i >= 0; $i--){
			my $len = scalar(@{$selfArrays[$i]});
			$result = ($len == scalar(@{$exprArrays[$i]}));
			unless($result){ last; }
			for(my $j = $len - 1; $j >= 0 and $result; $j--){
				my $selfItem = $selfArrays[$i]->[$j];
				my $exprItem = $exprArrays[$i]->[$j];
				$result = ($result and ($i == 0 ?
					$selfItem == $exprItem :
					$selfItem->isEquals($exprItem)));
			}
		}
		if($result){
				$result = (
					$self->id()					== $expr->id()		and
					$self->gameID()				== $expr->gameID()	and
					$self->caption()			eq $expr->caption()	and
					$self->isViewListInTop()	== $expr->isViewListInTop());
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	SQLを作成、取得します。
# RETURN STRING SQL構文。
sub sql{
	my $self = shift;
	my $result = 'SELECT ';
	for(my $i = 0; $i < 8; $i++){
		if($self->isViewList()->[$i]){ $result .= ($DIR::Ranking::COLUMN_NAME->[$i] . ','); }
	}
	chop($result);
	my $andString = ' AND ';
	$result .= (' FROM DIR_SCORE WHERE NOT (INJUSTICE OR WITHDRAW)' . $andString);
	foreach my $limit (@{$self->limitList()}){ $result .= ($limit->query() . $andString); }
	for(my $i = length($andString) - 1; $i >= 0; $i--){ chop($result); }
	$result .= ' ORDER BY ';
	foreach my $limit (@{$self->orderList()}){
		$result .= $limit->targetScoreColumnName();
		if($limit->order() > 0){ $result .= ' DESC'; }
		$result .= ',';
	}
	chop($result);
	$result .= ';';
	return $result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ランキングIDを取得します。
# RETURN NUM ランキングID。
sub id{
	my $self = shift;
	return $self->{id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム マスターIDを取得します。
# RETURN NUM ゲーム マスターID。
sub gameID{
	my $self = shift;
	return defined($self->{game}) ? $self->{game}->id() : $self->{game_id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ゲーム マスターを取得します。
# RETURN NUM ゲーム マスター情報オブジェクト。
sub game{
	my $self = shift;
	unless(defined($self->{game})){ $self->{game} = DIR::Game->newExist($self->gameID()); }
	return $self->{game};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ランキング名称を取得/設定します。
# PARAM STRING (省略可)新しいランキング名称
# RETURN STRING ランキング名称
sub caption{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{caption} = $value; }
	return $self->{caption};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	スコア表示フラグ一覧を取得します。
# RETURN \@ スコア表示フラグ一覧。
sub isViewList{
	my $self = shift;
	return $self->{view};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	絞込アイテム一覧を取得します。
# RETURN \@ 絞込アイテム一覧。
sub limitList{
	my $self = shift;
	return $self->{limit};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	並替アイテム一覧を取得します。
# RETURN \@ 並替アイテム一覧。
sub orderList{
	my $self = shift;
	return $self->{order};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ランキングTOPページにランキングリストを掲載するかどうか
# PARAM NUM (省略可)TOPページにランキングリストを掲載するかどうか
# RETURN NUM TOPページにランキングリストを掲載する場合、真値。
sub isViewListInTop{
	my $self = shift;
	my $value = shift;
	if(defined($value)){ $self->{top_list} = ($value ? 1 : 0); }
	return $self->{top_list};
}

1;

__END__
