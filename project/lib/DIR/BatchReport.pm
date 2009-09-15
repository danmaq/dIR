#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	バッチレポートのクラス。
#	1アカウントごとに1オブジェクトが割り当てられる。
package DIR::BatchReport;
use 5.006;
use strict;
use warnings;
use utf8;
use Jcode;
use DIR::DB;

$DIR::BatchReport::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id		=> undef,	# バッチ レポートID
	name	=> undef,	# バッチ名
	status	=> 0,		# 終了ステータス
	started	=> 0,		# 開始日時(UNIX時間)
	ended	=> 0,		# 終了日時(UNIX時間)
	notes	=> undef,	# 詳細報告
);

# TODO : ALL、未了、名称から検索

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	バッチレポートを新規作成します。
#	同時に、開始ログを取ります。
# PARAM STRING バッチ名
# RETURN \% バッチレポート情報の入ったオブジェクト。
sub new{
	my $class = shift;
	my $name = shift;
	my $result = undef;
	if(defined($name)){
		my $len = length($name);
		if($len > 0 && $len < 255){
			$result = bless({%s_fields}, $class);
			$result->{name} = $name;
			$result->{started} = time;
			$result->__commit();
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	存在するログからバッチレポートを新規作成します。
# PARAM NUM ログID
# RETURN \% バッチレポート情報の入ったオブジェクト。存在しない場合、未定義値。
sub newExist{
	my $class = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id){
		my $params = DIR::DB->instance()->readBatchReportFromID($id);
		if(defined($params)){
			$result = bless({%s_fields}, $class);
			$result->{id} = $params->{ID};
			$result->{name} = $params->{NAME};
			$result->{status} = $params->{STATUS};
			$result->{started} = $params->{STARTED};
			$result->{ended} = $params->{ENDED};
			$result->{notes} = $params->{NOTES};
		}
	}
	return $result;
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC INSTANCE
#	バッチの終了ログを取ります。
# PARAM NUM 終了ステータスコード
# PARAM STRING (省略可)詳細なメッセージ
# RETURN BOOLEAN 成功した場合、真値。
sub end{
	my $self = shift;
	my $status = shift;
	my $notes = shift;
	my $result = 0;
	if(!$self->isEnded() and defined($status)){
		$self->{status} = $status;
		$self->{notes} = $notes;
		$self->{ended} = time;
		$self->__commit();
		$result = 1;
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	オブジェクトが同等のものかどうかを取得します。
# PARAM \% バッチ レポート オブジェクト
# RETURN BOOLEAN オブジェクトが同等である場合、真値。
sub isEquals{
	my $self = shift;
	my $expr = shift;
	return (
		defined($expr)								and
		ref($expr)			eq 'DIR::BatchReport'	and
		$self->id()			== $expr->id()			and
		$self->name()		eq $expr->name()		and
		$self->status()		== $expr->status()		and
		$self->started()	== $expr->started()		and
		$self->ended()		== $expr->ended()		and
		$self->notes()		eq $expr->notes()
	);
}

############################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	バッチ名を取得します。
# RETURN STRING バッチ名。
sub name{
	my $self = shift;
	return $self->{name};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	終了ステータスを取得します。
# RETURN NUM 終了ステータスコード。
sub status{
	my $self = shift;
	return $self->{status};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	処理開始日時を取得します。
# RETURN NUM 処理開始日時(UNIX時間)。
sub started{
	my $self = shift;
	return $self->{started};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	処理終了日時を取得します。
# RETURN NUM 処理終了日時(UNIX時間)。
sub ended{
	my $self = shift;
	return $self->{ended};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	終了しているログかどうかを取得します。
# RETURN NUM 読み込み専用である場合、真値。
sub isEnded{
	my $self = shift;
	return ($self->ended() > 0);
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	バッチ レポートIDを取得します。
# RETURN NUM バッチ レポートID。存在しない場合、未定義値。
sub id{
	my $self = shift;
	return $self->{id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	このオブジェクトが一時的なものかどうかを取得します。
# RETURN BOOL 一時的なものである場合、真値。
sub temp{
	my $self = shift;
	return not defined($self->id());
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	詳細報告を取得します。
# RETURN NUM 詳細報告。存在しない場合、未定義値。
sub notes{
	my $self = shift;
	return $self->{notes};
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PRIVATE INSTANCE
#	バッチレポートをデータベースへコミットします。
sub __commit{
	my $self = shift;
	if($self->temp()){
		$self->{id} = DIR::DB->instance()->writeBatchReportStart($self->name());
	}
	else{
		my %params = (id => $self->id(), status => $self->status());
		if(defined($self->notes())){ $params{notes} = $self->notes(); }
		DIR::DB->instance()->writeBatchReportEnd(%params);
	}
}

1;

__END__
