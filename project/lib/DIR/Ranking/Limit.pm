#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	ランキング絞込条件アイテムのクラス。
#	1アイテムごとに1オブジェクトが割り当てられる。
package DIR::Ranking::Limit;
use 5.006;
use strict;
use warnings;
use utf8;
use DIR::DB;
use DIR::Validate;
use DIR::Ranking;

$DIR::Ranking::Limit::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id				=> 0,			# アイテムID
	rank_id			=> 0,			# ランキングID
	rank			=> undef,		# ランキング情報
	score_column	=> 0,			# 対象カラム
	threshold		=> 0,			# 閾値
	lo_pass			=> 214748647,	# 閾値以下許容誤差
	hi_pass			=> 214748647,	# 閾値以上許容誤差
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
		foreach my $info (DIR::DB->instance()->readRankingLimitFromGameID($ranking->id())){
			my $obj = DIR::Ranking::Limit->newAllParams(
				id				=> $info->{ID},
				rank_id			=> $ranking->id(),
				rank			=> $ranking,
				score_column	=> $info->{TARGET_COL},
				threshold		=> $info->{THRESHOLD},
				lo_pass			=> $info->{LO_PASS},
				hi_pass			=> $info->{HI_PASS});
			if(defined($obj)){ push(@result, $obj); }
		}
	}
	return @result;
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	絞込条件アイテムを新規作成します。
# PARAM \%(ranking score_column threshold lo_pass hi_pass)
#	ランキング情報、対象カラム、閾値、閾値以下許容誤差、閾値以上許容誤差
# RETURN \% 絞込条件アイテム情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my %args = @_;
	my $result = undef;
	if(
		DIR::Validate::isExistParameter(\%args, [qw(ranking score_column threshold lo_pass hi_pass)], 1) and
		ref($args{rank}) eq 'DIR::Ranking'
	){
		my $obj = bless({%s_fields}, $class);
		$obj->{rank_id}			= $args{rank}->id();
		$obj->{rank}			= $args{rank};
		$obj->{score_column}	= $args{score_column};
		$obj->{threshold}		= $args{threshold};
		$obj->{lo_pass}			= $args{lo_pass};
		$obj->{hi_pass}			= $args{hi_pass};
		if($obj->commit()){ $result = $obj; }
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	絞込条件アイテムIDから絞込条件アイテム情報を新規作成します。
# PARAM NUM 絞込条件アイテムID
# RETURN \% 絞込条件アイテム情報の入ったオブジェクト。存在しない場合、未定義値。
sub newExist{
	my $class = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $info = DIR::DB->instance()->readRankingLimitFromID($id);
		if(defined($info)){
			$result = bless({%s_fields}, $class);
			$result->{id}			= $id;
			$result->{rank_id}		= $info->{RANK_ID};
			$result->{score_column}	= $info->{TARGET_COL};
			$result->{threshold}	= $info->{THRESHOLD};
			$result->{lo_pass}		= $info->{LO_PASS};
			$result->{hi_pass}		= $info->{HI_PASS};
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
		DIR::Validate::isExistParameter(\%args, [qw(id rank_id)], 1, 1) and
		DIR::Validate::isExistParameter(\%args, [qw(score_column threshold lo_pass hi_pass)], 1) and
		DIR::Validate::isExistParameter(\%args, [qw(rank)])
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
		THRESHOLD	=> $self->threshold(),
		LO_PASS		=> $self->LowPass(),
		HI_PASS		=> $self->HighPass());
	if($self->id()){ $result = $db->writeRankingLimitUpdate(%args, ID =>$self->id()); }
	else{
		my $id = $db->writeRankingLimitInsert(%args);
		$result = (defined($id) and $id);
		if($result){ $self->{id} = $id; }
	}
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
		ref($expr)					eq 'DIR::Ranking::Limit'		and
		$self->id()					== $expr->id()					and
		$self->rankingID()			== $expr->rankingID()			and
		$self->targetScoreColumn()	== $expr->targetScoreColumn()	and
		$self->threshold()			== $expr->threshold()			and
		$self->LowPass()			== $expr->LowPass()				and
		$self->HighPass()			== $expr->HighPass());
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	絞込条件アイテムIDを取得します。
# RETURN NUM 絞込条件アイテムID。
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
#	閾値を取得/設定します。
# PARAM NUM (省略可)新しい閾値
# RETURN NUM 閾値
sub threshold{
	my $self = shift;
	my $value = shift;
	if(DIR::Validate::isNum($value)){ $self->{threshold} = $value; }
	return $self->{threshold};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	閾値以下許容誤差を取得/設定します。
# PARAM NUM (省略可)新しい閾値以下許容誤差
# RETURN NUM 閾値以下許容誤差
sub LowPass{
	my $self = shift;
	my $value = shift;
	if(DIR::Validate::isNum($value)){ $self->{lo_pass} = ($value >= 0 ? $value : 0); }
	return $self->{lo_pass};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	閾値以上許容誤差を取得/設定します。
# PARAM NUM (省略可)新しい閾値以上許容誤差
# RETURN NUM 閾値以上許容誤差
sub HighPass{
	my $self = shift;
	my $value = shift;
	if(DIR::Validate::isNum($value)){ $self->{hi_pass} = ($value >= 0 ? $value : 0); }
	return $self->{hi_pass};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	SQLクエリを取得します。
# RETURN STRING SQLクエリ。
sub query{
	my $self = shift;
	my $cname		= $self->targetScoreColumnName();
	my $threshold	= $self->threshold();
	return sprintf(
		'(%s <= (%d - %d) AND %s >= (%d + %d))',
		$cname, $threshold, $self->LowPass(),
		$cname, $threshold, $self->HighPass());
}

1;

__END__
