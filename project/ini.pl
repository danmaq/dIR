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

$DIR::DB::NAME = 'danmaq00001';		# データベース名
$DIR::DB::HOST = 'localhost';		# ホスト名
$DIR::DB::USER = 'danmaq00001';		# ユーザ名
$DIR::DB::PASS = 'zddscc';			# パスワード

=pod
$DIR::Template::DIR = './template';	# テンプレートファイル格納場所へのパス

$DIR::Output::NPH = 1;	# NPH(Non Parsed Header)を使用するかどうか
=cut

1;

__END__