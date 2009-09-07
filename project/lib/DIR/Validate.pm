#===============================================================================
#	dIR - danmaq Internet Ranking CGI
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	パラメータ検証機能をまとめた静的クラス。
package DIR::Validate;
use 5.006;
use strict;
use warnings;
use utf8;

$DIR::Validate::VERSION = 0.01;	# バージョン情報

#==========================================================
#==========================================================

#----------------------------------------------------------
# PUBLIC STATIC
#	パラメータハッシュに指定のキーが存在するかどうかを検証します。
# PARAM \%	チェック対象のパラメータハッシュ
# PARAM \@	有無を確認する配列
# PARAM NUM	nullチェック。省略時はチェックしない。
# PARAM NUM	真偽チェック。省略時はチェックしない。
# RETURN BOOL 指定のキーが存在しオプション指定に合致する場合、真値。
sub isExistParameter{
	my $args = shift;
	my $reqs = shift;
	my $null = shift;
	my $true = shift;
	my $result = (defined($args) and defined($reqs) and ref($args) and ref($reqs) eq 'ARRAY');
	if($result){
		foreach my $key(@$reqs){
			$result = ($result and exists($args->{ $key }));
			if($null){ $result = ($result and defined($args->{ $key })); }
			if($true){ $result = ($result and $args->{ $key }); }
			$result or last;
		}
	}
	return $result;
}

#----------------------------------------------------------
# PUBLIC STATIC
#	パラメータハッシュに指定のキーが存在するかどうかを検証します。
# PARAM \%	チェック対象のパラメータハッシュ
# PARAM \@	有無を確認する配列
# PARAM NUM	nullチェック。省略時はチェックしない。
# PARAM NUM	真偽チェック。省略時はチェックしない。
# RETURN BOOL 指定のキーが存在しオプション指定に合致する場合、真値。
sub isNum{
	my $num = shift;
	my $true = shift;
	return (defined($num) and not ref($num) and $num =~ /[0-9]/ and (not $true or $num));
}

#----------------------------------------------------------
# PUBLIC STATIC
#	値が指定幅に入るかどうかを検証します。
# PARAM STRING 文字列または数値
# PARAM 1 NUM 文字列幅
# PARAM 2 @[2] 最小値・最大値
# RETURN BOOL 指定のキーが存在しオプション指定に合致する場合、真値。
sub isLengthInRange{
	my $expr = shift;
	my @limit = @_;
	my $result = 0;
	my $mode = scalar(@limit);
	if(defined($expr) and $mode > 0){
		if($mode > 1){
			if($limit[0] == $limit[1]){ $mode = 1; }
			elsif($limit[0] > $limit[1]){
				my $temp = $limit[0];
				$limit[0] = $limit[1];
				$limit[1] = $temp;
			}
		}
		my $len = length($expr);
		$result = (($mode > 1) ? ($len >= $limit[0] and $len <= $limit[1]) : $len == $limit[0]);
	}
	return $result;
}

1;

__END__
