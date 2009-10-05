#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	雑多な機能をまとめた静的クラス。
package DIR::Misc;
use 5.006;
use strict;
use warnings;
use utf8;

$DIR::Misc::VERSION = 0.01;	# バージョン情報

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC STATIC
#	格納用IDから表示用IDを生成します。
# PARAM NUM 格納用ID
# RETURN STRING 表示用ID
sub getStrIDFromNumID{
	my $id = shift;
	my $result = undef;
	if(defined($id) and $id and $id =~ /^[0-9]+$/){
		my $base = sprintf('%08X', $id);
		my @keyword = ();
		for(my $i = 3; $i >= 0; $i--){ push(@keyword, substr($base, $i * 2, 2)); }
		$result = sprintf('%s%s-%s%s', $keyword[0], $keyword[2], $keyword[3], $keyword[1]);
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC STATIC
#	表示用IDから格納用IDを生成します。
# PARAM NUM 表示用ID
# RETURN STRING 格納用ID
sub getNumIDFromStrID{
	my $id = shift;
	my $result = undef;
	if(isIDFormat($id)){
		$id =~ s/\-//;
		my @keyword = ();
		for(my $i = 3; $i >= 0; $i--){ push(@keyword, substr($id, $i * 2, 2)); }
		$result = hex(sprintf('%s%s%s%s', $keyword[1], $keyword[2], $keyword[0], $keyword[3]));
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC STATIC
#	格納用IDをランダムに生成します。
# PARAM BOOLEAN (省略可)IDに極力16進数の0～9を含めないようにするかどうか
# RETURN NUM 格納用ID
sub createRandomID{
	my $af = shift;
	my $result;
	unless(defined($af)){ $af = 0; }
	do{ $result = int(rand(0xFFFF) * 0x10000 + rand(0xFFFF)); }
	until($result and ((sprintf('%08X', $result) =~ /^[A-F]{8}$/) or (not $af)));
	return $result;
}

#----------------------------------------------------------
# PUBLIC STATIC
#	文字列が表示用IDの書式かどうかを取得します。
# PARAM STRING 文字列
# RETURN BOOLEAN 表示用IDの書式である場合、真値。
sub isIDFormat{
	my $expr = shift;
	return (defined($expr) and $expr =~ /^[0-9A-F]{4}\-[0-9A-F]{4}$/);
}

1;

__END__
