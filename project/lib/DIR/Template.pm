#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	テンプレートファイル入力用の静的クラス。
# ! NOTE : このクラス使用前に外部から$DIR::Template::DIRを設定してください。
package DIR::Template;
use 5.006;
use strict;
use warnings;
use utf8;
use IO::File;
use HTML::Template;

use constant FILE_HTT_FRAME	=> 'html/frame.htt';

use constant FILE_SQL_DDL								=> 'sql/table.sql';
use constant FILE_SQL_NOWTIME							=> 'sql/nowTime.sql';
use constant FILE_SQL_BATCHREPORT_INSERT				=> 'sql/BatchReport/insert.sql';
use constant FILE_SQL_BATCHREPORT_UPDATE_WITH_NOTES		=> 'sql/BatchReport/updateWithNotes.sql';
use constant FILE_SQL_BATCHREPORT_UPDATE_WITHOUT_NOTES	=> 'sql/BatchReport/updateWithoutNotes.sql';
use constant FILE_SQL_BATCHREPORT_SELECT_FROMID			=> 'sql/BatchReport/selectFromID.sql';
use constant FILE_SQL_BATCHREPORT_SELECT_LASTID			=> 'sql/BatchReport/selectLastID.sql';
use constant FILE_SQL_USER_INSERT						=> 'sql/User/insert.sql';
use constant FILE_SQL_USER_SELECT_FROMID				=> 'sql/User/selectFromID.sql';
use constant FILE_SQL_USER_UPDATE						=> 'sql/User/update.sql';
use constant FILE_SQL_USER_UPDATE_LOGIN					=> 'sql/User/updateLogin.sql';
use constant FILE_SQL_USER_EMAIL_INSERT					=> 'sql/User/EMail/insert.sql';
use constant FILE_SQL_USER_EMAIL_UPDATE					=> 'sql/User/EMail/update.sql';
use constant FILE_SQL_USER_EMAIL_SELECT_FROM_URI		=> 'sql/User/EMail/selectFromEMail.sql';
use constant FILE_SQL_USER_EMAIL_SELECT_FROM_UID		=> 'sql/User/EMail/selectFromURI.sql';

$DIR::Template::VERSION = 0.01;	# バージョン情報

### 設定項目ここから
$DIR::Template::DIR = '';	# テンプレートファイル格納フォルダを指定します。
### 設定項目おわり

my %cache = ();

#==========================================================
#==========================================================

#------------------------------------------------------------------------------
# PUBLIC STATIC
# 	パスを取得します。
# PARAM STRING ファイル名文字列
# RETURN STRING パス
sub getPath{ return $DIR::Template::DIR . '/' . (shift); }

#------------------------------------------------------------------------------
# PUBLIC STATIC
# 	テンプレート ファイルを読み込みます。
# 	sprintfと同等の書式変換が使用可能です。
# PARAM STRING ファイル名文字列
# PARAM ... 置き換える可変個引数
# RETURN STRING ファイルの内容文字列
sub get{
	my $fname = getPath(shift);
	my $result = undef;
	my @options = @_;
	my $buffer = (exists($cache{ $fname }) ? $cache{ $fname } : undef);
	for(0..255){ push(@options, ''); }	# ! XXX :この実装いくらなんでもテキトーすぎだろjk
	if(not defined($buffer) and -e $fname and -f $fname){
		my $fh = IO::File->new($fname, O_RDONLY);
		$fh->read($buffer, -s $fname);
		$fh->close();
		$cache{ $fname } = $buffer;
	}
	if(defined($buffer)){ $result = sprintf($buffer, @options); }
	return $result;
}

#------------------------------------------------------------------------------
# PUBLIC STATIC
# 	テンプレート ファイルを読み込みます。
# HTML::Templateと同等の書式変換が使用可能です。
# PARAM STRING ファイル名文字列
# PARAM ... 置き換える可変個引数
# RETURN STRING ファイルの内容文字列
sub getHTT{
	my $fname = getPath(shift);
	my $result = undef;
	if(-e $fname and -f $fname){
		my %options = @_;
		my $template = HTML::Template->new(filename => $fname);
		my @key = keys(%options);
		foreach my $item (@key){ $template->param($item => $options{ $item }); }
		$result = $template->output();
	}
	return $result;
}

1;

__END__
