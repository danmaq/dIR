use 5.006;
use strict;
use warnings;


my $mail_regex =
	q{(?:[-!#-'*+/-9=?A-Z^-~]+(?:\.[-!#-'*+/-9=?A-Z^-~]+)*|"(?:[!#-\[\]-} .
	q{~]|\\\\[\x09 -~])*")@[-!#-'*+/-9=?A-Z^-~]+(?:\.[-!#-'*+/-9=?A-Z^-~]+} .
	q{)*};

print ('info@danmaq.com' =~ /^$mail_regex\z/o ? 'Valid' : 'Invalid');