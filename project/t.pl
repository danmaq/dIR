package Foo;
use strict;
use warnings;

sub new{ return bless( { a => 'A' }, shift ); }
sub p{
	my $self = shift;
	return ('hoge' . $self->{a});
}

package Bar;
use strict;
use warnings;
use base qw(Foo);

sub new{
	my $self = bless( Foo->new(), shift );
	$self->{ a } = 'B';
	return $self;
}
sub p;
{
	my $old = \&Foo::p;
	my $new = sub{
		my $self = shift;
		return ('fuga' . $self->{a}) . ($old->($self));
	};
	{
		no warnings qw( redefine );
		*Bar::p = $new;
	}
}

package main;

my $f = Foo->new();
my $b = Bar->new();
print $f->p();
print "\n";
print $b->p();
print "\n";
