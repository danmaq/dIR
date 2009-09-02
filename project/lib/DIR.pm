#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	バージョン情報取得 クラス。
package DIR;
use 5.006;
use strict;
use warnings;
use utf8;

$DIR::VERSION_STRING = '0';			# バージョン文字列(短)

$DIR::VERSION =	# バージョン情報
	0.01;

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC STATIC
#	ビルド番号を取得します。
# RETURN NUM ビルド番号
sub buildNumber{ return $DIR::VERSION * 100; }

#----------------------------------------------------------
# PUBLIC STATIC
#	短いバージョン情報文字列を取得します。
# RETURN STRING 短いバージョン情報文字列
sub versionShort{ return sprintf('%s.%d', $DIR::VERSION_STRING, buildNumber()); }

#----------------------------------------------------------
# PUBLIC STATIC
#	長いバージョン情報文字列を取得します。
# RETURN STRING 長いバージョン情報文字列
sub versionLong{
	return sprintf('%s ビルド %d',
		$DIR::VERSION_STRING, buildNumber());
}

1;

__END__
