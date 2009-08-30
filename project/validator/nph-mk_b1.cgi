#!/usr/local/bin/perl
use 5.004;
use CGI qw(-nph);

sub validate{
	unless(scalar(@_) == 1){ return -1; }
	my $expr1 = shift;
	unless($expr1 =~ /^\d+\-\d+$/){ return -2; }
	my @expr2 = split( /-/g, $expr1);
	unless(scalar(@expr2) == 2){ return -3; }
	my $result = $expr2[0] / $expr2[1];
	if($result =~ /\./){ return -4; }
	return $result;
}

my $cgi = CGI->new();

my $result = validate($cgi->keywords());
print $cgi->header(-content_type => 'text/plain');
print $result . "\n";
__END__
