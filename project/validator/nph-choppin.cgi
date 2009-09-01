#!/usr/local/bin/perl
use 5.004;
use CGI qw(-nph);

my $status = 0;
my @result = qw(0 0 0 0 0 0 0 0);
sub validate{
	unless(scalar(@_) == 1){ return -1; }
	my $expr1 = shift;
	unless($expr1 =~ /^\d{3}\-\d+G3\d{2,3}$/){ return -2; }
	my @expr2 = split(/[\-G]/, $expr1);
	unless(scalar(@expr2) == 3){ return -3; }
	unless($expr2[0] == 128){ return -4; }
	unless($expr2[1] > 0){ return -5; }
	$expr2[2] =~ s/^3//;
	unless($expr2[2] > 0){ return -6; }
	$expr2[1] /= $expr2[2];
	if($expr2[1] =~ /\./){ return -7; }
	my $chopped = $expr2[1] % 1000;
	my $chopbonus = int($expr2[1] / 1000);
	while($chopbonus % 10 == 0){ chop($chopbonus); }
	$result[1] = $chopbonus;
	$result[2] = $chopped;
	$result[3] = $chopped * 3000;
	$result[0] = $chopbonus + $result[3];
	return 0;
}

my $cgi = CGI->new();
$body = sprintf('%s;', validate($cgi->keywords()));
$body .= "@result\n";
print $cgi->header(-content_type => 'text/plain', -content_length => length($body));
print $body;

__END__
