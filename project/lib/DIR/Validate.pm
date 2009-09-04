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

1;

__END__
