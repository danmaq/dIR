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
use Time::localtime;
use XML::Twig;
use DIR;
use DIR::Output::Account;
use DIR::Output::Misc;
use DIR::Output::Ranking;

$DIR::Output::VERSION =		# バージョン情報
	$DIR::Output::Account::VERSION +
	$DIR::Output::Misc::VERSION +
	$DIR::Output::Ranking::VERSION +
	0.01;

### 設定項目ここから
$DIR::Output::NPH	= 1;	# NPH(Non Parsed Header)を使用するかどうか
$DIR::Output::TWIG	= 1;	# HTMLを整形するかどうか
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
# PARAM \% (省略可)追加ヘッダ
sub _put{
	my $self = shift;
	my $body = Jcode->new(DIR::Template::getHTT(DIR::Const::FILE_HTT_FRAME,
		VERSION => DIR::versionShort(), BODY => shift), 'utf8')->utf8();
	my $additional = shift;
	unless(defined($additional)){ $additional = {}; }
	if($DIR::Output::TWIG){
		my $twig = XML::Twig->new();
		$twig->set_indent("\t");
		$twig->parse($body);
		$twig->set_pretty_print('indented');
		$twig->trim();
		$body = Jcode->new($twig->sprint(), 'utf8')->utf8();
	}
	print DIR::Input->instance()->cgi()->header(
		-nph			=> $DIR::Output::NPH,
		-cookie			=> DIR::Input->instance()->cookie(),
		-charset		=> 'UTF-8',
		-content_length	=> length($body),
		-Pragma			=> 'no-cache',
		-Cache_Control	=> 'no-cache, must-revalidate',
		%$additional);
	print $body;
}

#----------------------------------------------------------
# PRIVATE INSTANCE
# 	リダイレクト ヘッダを出力します。
# PARAM STRING URI
# PARAM \% (省略可)追加ヘッダ
sub _redirect{
	my $self = shift;
	my $uri = shift;
	my $additional = shift;
	my $cgi = DIR::Input->instance()->cgi();
	unless(defined($additional)){	$additional = {};	}
	unless(defined($uri)){			$uri = '/';			}
	$uri = $cgi->url() . $uri;
	$uri =~ s/\/+\?/\/\?/g;
	$uri =~ s/\/+$/\//g;
	print $cgi->redirect(
		-nph			=> $DIR::Output::NPH,
		-cookie			=> DIR::Input->instance()->cookie(),
		-uri			=> $uri,
		%$additional);
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
