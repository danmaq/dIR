#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	データベース入出力クラス。
#	シングルトン。
# ! NOTE : このクラス使用前に外部から設定項目を変更してください。
package DIR::DB;
use 5.006;
use strict;
use warnings;
use utf8;
use base 'Class::Singleton';
use Jcode;
use DBI qw(:sql_types);
use DIR::Input;
use DIR::DB::BatchReport;
use DIR::DB::EMail;
use DIR::DB::Game;
use DIR::DB::Publisher;
use DIR::DB::User;

$DIR::DB::VERSION =	# バージョン情報
	$DIR::DB::BatchReport::VERSION +
	$DIR::DB::EMail::VERSION +
	$DIR::DB::Game::VERSION +
	$DIR::DB::Publisher::VERSION +
	$DIR::DB::User::VERSION +
	0.01;

### 設定項目ここから
$DIR::DB::NAME = '';	# データベース名を指定します。
$DIR::DB::HOST = '';	# ホスト名を指定します。
$DIR::DB::USER = '';	# ユーザ名を指定します。
$DIR::DB::PASS = '';	# パスワードを指定します。
### 設定項目おわり

my %s_fields = (	# フィールド
	dbi => undef,
);

#==========================================================
#==========================================================

# TODO : selectTableLastIDってselectSingleColumnで代用できるんじゃね？

#----------------------------------------------------------
# PUBLIC INSTANCE
#	各テーブルにて最後に設定したIDを取得します。
# RETURN NUM 定義ID
sub selectTableLastID{
	my $self = shift;
	my $file = shift;
	my $result = undef;
	my $sql = $self->_execute($file);
	if(ref($sql)){
		my $row = $sql->fetchrow_hashref();
		if(defined($row)){ $result = $row->{ ID }; }
		$sql->finish();
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	全件検索します。
# PARAM STRING SQLファイル名
# PARAM @ SQLに渡す値
# RETURN @ 検索結果一覧
sub selectAll{
	my $self = shift;
	my $sql = $self->_execute(@_);
	my @result = ();
	if(ref($sql)){
		while(my $row = $sql->fetchrow_hashref()){ push(@result, $row); }
		$sql->finish();
	}
	return @result;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	特定カラム名のみ1件検索します。
# PARAM STRING SQLファイル名
# PARAM STRING カラム名
# PARAM @ SQLに渡す値
# RETURN $ 検索結果
sub selectSingleColumn{
	my $self = shift;
	my @result = $self->selectAllSingleColumn(@_);
	return scalar(@result) > 0 ? $result[0] : undef;
}

#----------------------------------------------------------
# PUBLIC INSTANCE
#	特定カラム名のみ全件検索します。
# PARAM STRING SQLファイル名
# PARAM STRING カラム名
# PARAM @ SQLに渡す値
# RETURN @ 検索結果一覧
sub selectAllSingleColumn{
	my $self = shift;
	my $file = shift;
	my $column = shift;
	my $sql = $self->_execute($file, @_);
	my @result = ();
	if(ref($sql)){
		while(my $row = $sql->fetchrow_hashref()){ push(@result, $row->{ $column }); }
		$sql->finish();
	}
	return @result;
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	データベースを閉じます。
#	プログラム終了前に必ず呼び出してください。
sub dispose{
	my $self = shift;
	if(defined($self->dbi())){
		DIR::Input->instance()->dispose();
		$self->dbi()->commit();
		$self->dbi()->disconnect();
		$self->{ dbi } = undef;
	}
}

###########################################################

#----------------------------------------------------------
# PUBLIC INSTANCE
#	DBIオブジェクトを取得します。
# RETURN \% DBIオブジェクト
sub dbi{
	my $self = shift;
	return $self->{ dbi };
}

#==========================================================
#==========================================================

#------------------------------------------------------------------------------
# PRIVATE NEW
# 	インスタンスを作成します。
#	インスタンス取得時に1度だけ自動的に呼び出されます。
# RETURN \% オブジェクト
sub _new_instance{
	my $self = bless({ %s_fields }, shift);
	my $dbi = DBI->connect(
		sprintf('DBI:mysql:database=%s;host=%s', $DIR::DB::NAME, $DIR::DB::HOST),
		$DIR::DB::USER, $DIR::DB::PASS);
	$dbi->do('SET NAMES utf8;');
	$dbi->{ AutoCommit } = 0;
#	$dbi->{ TraceLevel } = "0|SQL";
#	open(STDERR, ">&STDOUT");
	$self->{ dbi } = $dbi;
	return $self;
}

#==========================================================
#==========================================================

#------------------------------------------------------------------------------
# PRIVATE INSTANCE
# 	SQLを実行します。
# PARAM STRING SQLファイル名
# 1 PARAM @ SQLパラメータ
# 2 PARAM @\%(type value) SQLパラメータの型と値のセット
# RETURN DBI::stオブジェクト、返すものがない場合1、失敗した場合0。
# !!! XXX !!! : 値から型を判断するのは良くない。最終的に型と引数の両方を渡すべき
sub _execute{
	my $self = shift;
	my $result = 0;
	my $sql = $self->dbi()->prepare(DIR::Template::get(shift));
	if(defined($sql)){
		$result = 1;
		my @args = @_;
		my $len = scalar(@args);
		my $param;
		my $manual;
		for(my $i = 0; $i < $len; $i++){
			$param = $args[$i];
			$manual = ref($param);
			$sql->bind_param($i + 1, $manual ? $param->{ value } : $param,
				$manual ? $param->{ type } :
				(defined($param) and $param =~ /^-?\d+$/ ? SQL_INTEGER : undef));
		}
		$sql->execute();
		if($sql->rows()){ $result = $sql; }
		else{
			$result = 1;
			$sql->finish();
		}
	}
	return $result;
}

1;

__END__
