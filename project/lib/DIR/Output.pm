#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	Web出力を司るクラス。
#	シングルトン。
package DIR::Output;
use 5.006;
use strict;
use warnings;
use utf8;
use base 'Class::Singleton';
use Jcode;
use XML::Twig;
use DIR;
use DIR::Output::Misc;

$DIR::Output::VERSION =		# バージョン情報
	$DIR::Output::Misc::VERSION +
	0.01;

### 設定項目ここから
$DIR::Output::NPH = 1;	# NPH(Non Parsed Header)を使用するかどうか
### 設定項目おわり

my %s_fields = ();	# フィールド

#==========================================================
#==========================================================

#----------------------------------------------------------
# PRIVATE NEW
# 	インスタンスを作成します。
#	インスタンス取得時に1度だけ自動的に呼び出されます。
# RETURN \% オブジェクト
sub _new_instance{
	my $self = bless({ %s_fields }, shift);
	binmode(STDIN, ':bytes');
	return $self;
}

#==========================================================
#==========================================================

#----------------------------------------------------------
# PRIVATE INSTANCE
# 	画面を表示します。
# PARAM STRING HTML本体文字列
sub _put{
	my $self = shift;
	my $body = Jcode->new(DIR::Template::getHTT(DIR::Template::FILE_HTT_FRAME,
		VERSION => DIR::versionShort(), BODY => shift), 'utf8')->utf8();
	my $twig = XML::Twig->new();
	$twig->set_indent("\t");
	$twig->parse($body);
	$twig->set_pretty_print('indented');
	$twig->trim();
	$body = Jcode->new($twig->sprint(), 'utf8')->utf8();
	print DIR::Input->instance()->cgi()->header(
		-nph			=> $DIR::Output::NPH,
		-cookie			=> DIR::Input->instance()->cookie(),
		-charset		=> 'UTF-8',
		-content_length	=> length($body),
		-Pragma			=> 'no-cache',
		-Cache_Control	=> 'no-cache, must-revalidate');
	print $body;
}

#----------------------------------------------------------
# PRIVATE INSTANCE
# 	タイムスタンプ文字列を作成します。
# PARAM STRING タイムスタンプ文字列
sub _createTimeStamp{
	shift;
	my $ltime = localtime(shift);
	return sprintf('%d/%d/%d %d:%d',
		1900 + $ltime->year(), 1 + $ltime->mon(), $ltime->mday(), $ltime->hour(), $ltime->min());
}

1;

__END__
