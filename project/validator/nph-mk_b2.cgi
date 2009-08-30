#!/usr/local/bin/perl
use 5.004;
use CGI qw(-nph);

sub validate{
	unless(scalar(@_) == 1){ return -1; }
	my $expr1 = shift;
	unless($expr1 =~ /^\d{3}\-\d+\-3C\d$/){ return -2; }
	my @expr2 = split(/[\-C]/, $expr1);
	unless(scalar(@expr2) == 4){ return -3; }
	if($expr2[1] == 0){ return 0; }
	
	return length($expr2[0]);
}

my $cgi = CGI->new();

my $result = validate($cgi->keywords());
print $cgi->header(-content_type => 'text/plain');
print $result . "\n";
__END__
