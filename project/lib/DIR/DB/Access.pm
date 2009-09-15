#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	アクセスログ情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::Access;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use Jcode;
use DIR::Template;
use DIR::Validate;

$DIR::DB::Access::VERSION = 0.01;	# バージョン情報

@DIR::DB::Access::ISA = qw(Exporter);
@DIR::DB::Access::EXPORT = qw(
);

#==========================================================
#==========================================================


1;

__END__
