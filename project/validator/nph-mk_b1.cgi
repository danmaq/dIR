#!/usr/local/bin/perl
#===============================================================================
#	dIR - danmaq Internet Ranking CGI (Validator Module)
#		(c)2009 danmaq All rights reserved.
#===============================================================================
#	MAKIWARI 2K(Mk-IIK) beta1用パスワード検証モジュール。
use 5.004;
use strict;
use warnings;
use utf8;
use CGI qw(-nph);

my $status = 0;
my @result = qw(0 0 0 0 0 0 0 0);
sub validate{
	unless(scalar(@_) == 1){ return -1; }				# パスワードがない？
	my $expr1 = shift;
	unless($expr1 =~ /^\d+\-\d+$/){ return -2; }		# 違うパスワード
	my @expr2 = split( /-/g, $expr1);
	unless($expr2[0] % $expr2[1] == 0){ return -3; }	# パスワードが不正
	my $score = $expr2[0] / $expr2[1];
	$result[0] = $score;
	return 0;
}

my $cgi = CGI->new();
my $body = sprintf('%s;', validate($cgi->keywords()));
$body .= "@result\n";
print $cgi->header(-content_type => 'text/plain', -content_length => length($body));
print $body;

__END__
