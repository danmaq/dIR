#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	設定ファイル。
# ! NOTE : 中を覗かれないようアップロード時に実行属性を付けること。
use 5.006;
use strict;
use warnings;
use lib qw(. ./lib);
use utf8;
use CGI qw(-compile);
use DIR;
#use DIR::DB;
#use DIR::Template;

use constant DIR_INI => 1;

select(STDERR); $| = 1;
select(STDOUT); $| = 1;

$DIR::VERSION_STRING = '0.0.1';

=pod
$DIR::DB::NAME = 'prodigy-inc';								# データベース名
$DIR::DB::HOST = CGI->new()->remote_addr() eq '127.0.0.1' ?	# ホスト名
	'localhost' : 'mysql207.db.sakura.ne.jp';
$DIR::DB::USER = 'prodigy-inc';								# ユーザ名
$DIR::DB::PASS = 'prodiby';									# パスワード

$DIR::Template::DIR = './template';	# テンプレートファイル格納場所へのパス

$DIR::Output::NPH = 1;	# NPH(Non Parsed Header)を使用するかどうか
=cut

1;

__END__
