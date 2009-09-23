#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	スコア情報のデータベース入出力クラス。
# ! NOTE : このクラスは、実質DIR::DBの一部として機能します。
package DIR::DB::Score;
use 5.006;
use strict;
use warnings;
use utf8;
use DBI qw(:sql_types);
use Exporter;
use DIR::Template;
use DIR::Validate;

$DIR::DB::Score::VERSION = 0.01;	# バージョン情報

@DIR::DB::Score::ISA = qw(Exporter);
@DIR::DB::Score::EXPORT = qw(
);

#==========================================================
#==========================================================


1;

__END__
