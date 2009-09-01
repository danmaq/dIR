#!/usr/local/bin/perl
use 5.004;
use CGI qw(-nph);

my $status = 0;
my @result = qw(0 0 0 0 0 0 0 0);
sub validate{
	unless(scalar(@_) == 1){ return -1; }					# パスワードがない
	my $expr1 = shift;
	unless($expr1 =~ /^\d{3}\-\d+\-3C\d$/){ return -2; }	# 違うパスワード
	my @expr2 = split(/[\-C]/, $expr1);
	if($expr2[1] == 0){ return -3; }						# 保存対象外
	my $len = length($expr2[1]);
	if($len < 10){ return -4; }								# パスワード不正
	for(my $i = 3; $i <= 5; $i++){
		my $maki = substr($expr2[1], 0, $i);
		if($i < 5 && substr($expr2[1], $i, 1) == 0){ $maki = substr($expr2[1], 0, $i + 1); }
		if($maki % $expr2[0] == 0){
			for(my $j = 3; $j <= $i; $j++){
				my $combo = substr($expr2[1], $len - $j);
				if($combo % $expr2[0] == 0){
					my $score = substr($expr2[1], $i, $len - $i - $j);
					if($score % $expr2[0] == 0){
						$result[0] = $score / $expr2[0];
						$result[1] = $maki / $expr2[0];
						$result[2] = $combo / $expr2[0];
						return 0;
					}
				}
			}
		}
	}
	return -5;												# パスワード不正
}

my $cgi = CGI->new();
$body = sprintf('%s;', validate($cgi->keywords()));
$body .= "@result\n";
print $cgi->header(-content_type => 'text/plain', -content_length => length($body));
print $body;

__END__
