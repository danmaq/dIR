#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	バッチレポートのクラス。
#	1アカウントごとに1インスタンスが割り当てられる。
package DIR::BatchReport;
use 5.006;
use strict;
use warnings;
use utf8;
use Jcode;
use DIR::DB;

$DIR::BatchReport::VERSION = 0.01;	# バージョン情報

my %s_fields = (	# フィールド
	id		=> undef,	# バッチID
	name	=> undef,	# バッチ名
	status	=> 0,		# 終了ステータス
	started	=> 0,		# 開始日時(UNIX時間)
	ended	=> 0,		# 終了日時(UNIX時間)
	notes	=> undef,	# 詳細報告
);

# TODO : new_exist、ALL、名称から検索

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC NEW
#	バッチレポートを新規作成します。
#	同時に、開始ログを取ります。
# PARAM STRING バッチ名
# RETURN \% 定義情報の入ったインスタンス。
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
			$result->commit();
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC NEW
#	存在するログからバッチレポートを新規作成します。
# PARAM NUM ログID
# RETURN \% 定義情報の入ったインスタンス。
sub new_exist{
	my $class = shift;
	my $id = shift;
	my $result = undef;
	if(defined($id) && $id){
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	バッチレポートをデータベースへコミットします。
sub commit{
	my $self = shift;
	if($self->temp()){
		$self->{id} = DIR::DB->instance()->writeBatchReportStart($self->name());
	}
	else{
		my %params = (id => $self->id(), status => $self->status());
		if(defined($self->notes())){ push(%params, notes => $self->notes()); }
		DIR::DB->instance()->writeBatchReportEnd(%params);
	}
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	バッチの終了ログを取ります。
# PARAM NUM 終了ステータスコード
# PARAM STRING (省略可)詳細なメッセージ
sub end{
	my $self = shift;
	my $status = shift;
	my $notes = shift;
	my $result = 0;
	$self->{status} = $status;
	$self->{notes} = $notes;
	$self->{ended} = time;
	$self->commit();
	return $result;
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
#	バッチIDを取得します。
# RETURN NUM バッチID。存在しない場合、未定義値。
sub id{
	my $self = shift;
	return $self->{id};
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	このインスタンスが一時的なものかどうかを取得します。
# RETURN BOOL 一時的なものである場合、真値。
sub temp{
	my $self = shift;
	return not defined($self->id());
}

1;

__END__
