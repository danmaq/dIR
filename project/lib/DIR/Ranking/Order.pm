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
use DIR::DB;
use DIR::Validate;
use DIR::Ranking;

$DIR::Ranking::Order::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id				=> 0,		# アイテムID
	rank_id			=> 0,		# ランキングID
	rank			=> undef,	# ランキング情報
	target_column	=> 0,		# 対象カラム
	order			=> 0,		# 昇降順順序
);

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC STATIC
#	ランキング定義情報から絞込条件アイテム一覧を作成します。
# PARAM \% ランキング定義情報
# RETURN @\% 絞込条件アイテムの入ったオブジェクト一覧。
sub listNewFromRanking{
	my @result = ();
	my $ranking = shift;
	if(defined($ranking) and ref($ranking) eq 'DIR::Ranking'){
		foreach my $info (DIR::DB->instance()->readRankingOrderFromGameID($ranking->id())){
			my $obj = DIR::Ranking::Order->newAllParams(
				id				=> $info->{ID},
				rank_id			=> $ranking->id(),
				rank			=> $ranking,
				score_column	=> $info->{TARGET_COL},
				order			=> $info->{RANK_ORDER});
			if(defined($obj)){ push(@result, $obj); }
		}
	}
	return @result;
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	並替条件アイテムを新規作成します。
# PARAM \%(ranking score_column order) ランキング情報、対象カラム、昇降順順序
# RETURN \% 並替条件アイテム情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(ranking order)], 1, 1) and
		DIR::Validate::isExistParameter(\%args, [qw(score_column)], 1) and
		ref($args{rank}) eq 'DIR::Ranking' and $args{score_column} =~ /^[0-7]$/
	){
		my $obj = bless({%s_fields}, $class);
		$obj->{rank_id}			= $args{rank}->id();
		$obj->{rank}			= $args{rank};
		$obj->{score_column}	= $args{score_column};
		$obj->{order}			= $args{order};
		if($obj->commit()){ $result = $obj; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	並替条件アイテムIDから並替条件アイテム情報を新規作成します。
# PARAM NUM 並替条件アイテムID
# RETURN \% 並替条件アイテム情報の入ったオブジェクト。存在しない場合、未定義値。
sub newExist{
	my $class = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $info = DIR::DB->instance()->readRankingOrderFromID($id);
		if(defined($info)){
			$result = bless({%s_fields}, $class);
			$result->{id}			= $id;
			$result->{rank_id}		= $info->{RANK_ID};
			$result->{score_column}	= $info->{TARGET_COL};
			$result->{order}		= $info->{RANK_ORDER};
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	パラメータを手動指定して絞込条件アイテム情報を新規作成します。
# PARAM % フィールド全部
# RETURN \% 絞込条件アイテム情報の入ったオブジェクト。
sub newAllParams{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(id rank_id order)], 1, 1) and
		DIR::Validate::isExistParameter(\%args, [qw(score_column)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(rank)]) and
		$args{score_column} =~ /^[0-7]$/
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
		RANK_ID		=> $self->rankingID(),
		TARGET_COL	=> $self->targetScoreColumn(),
		RANK_ORDER	=> $self->order());
	if($self->id()){ $result = $db->writeRankingOrderUpdate(%args, ID =>$self->id()); }
	else{
		my $id = $db->writeRankingOrderInsert(%args);
		$result = (defined($id) and $id);
		if($result){ $self->{id} = $id; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	情報をデータベースから削除します。
#	その際にオブジェクトも初期化されます。
# RETURN BOOLEAN オブジェクトを削除できた場合、真値。
sub remove{
	my $self = shift;
	my $result = DIR::DB->instance()->eraseRankingOrder($self->id());
	if($result){ %$self = %s_fields; }
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトが同等のものかどうかを取得します。
# PARAM \% スコア情報オブジェクト
# RETURN BOOLEAN オブジェクトが同等である場合、真値。
sub isEquals{
	my $self = shift;
	my $expr = shift;
	return (
		defined($expr)												and
		ref($expr)					eq 'DIR::Ranking::Order'		and
		$self->id()					== $expr->id()					and
		$self->rankingID()			== $expr->rankingID()			and
		$self->targetScoreColumn()	== $expr->targetScoreColumn()	and
		$self->threshold()			== $expr->order());
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	並替条件アイテムIDを取得します。
# RETURN NUM 並替条件アイテムID。
sub id{
	my $self = shift;
	return $self->{id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ランキングIDを取得します。
# RETURN \% ランキングID。
sub rankingID{
	my $self = shift;
	return defined($self->{rank}) ? $self->{rank}->id() : $self->{rank_id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	ランキング情報を取得します。
# RETURN \% ランキング情報オブジェクト。
sub ranking{
	my $self = shift;
	if(defined($self->{rank})){ $self->{rank} = DIR::Ranking->newExist($self->{rank_id}); }
	return $self->{rank};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	対象カラムを取得/設定します。
# PARAM NUM (省略可)新しい対象カラム
# RETURN NUM 対象カラム
sub targetScoreColumn{
	my $self = shift;
	my $value = shift;
	if(defined($value) and $value =~ /^[0-7]$/){ $self->{score_column} = $value; }
	return $self->{score_column};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	対象カラムの名前を取得します。
# RETURN STRING 対象カラムの名前
sub targetScoreColumnName{
	my $self = shift;
	return $DIR::Ranking::COLUMN_NAME->[$self->targetScoreColumn()];
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	昇降順順序を取得/設定します。
# PARAM NUM (省略可)新しい昇降順順序
# RETURN NUM 昇降順順序
sub order{
	my $self = shift;
	my $value = shift;
	if(DIR::Validate::isNum($value) and $value){ $self->{order} = $value; }
	return $self->{order};
}

1;

__END__
