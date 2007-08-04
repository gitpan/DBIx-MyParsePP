use strict;

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl simple.t'

#########################

use Test::More tests => 11;

BEGIN { use_ok('DBIx::MyParsePP::Lexer') };
BEGIN { use_ok('DBIx::MyParsePP::Token') };

my $token_class = 'DBIx::MyParsePP::Token';

my $lexer = DBIx::MyParsePP::Lexer->new($ARGV[0]);

use Data::Dumper;
my @tokens;
while (1) {
	my $token = $lexer->yylex();
	print Dumper \$token;
	print "len is ".length($token->value())."\n";
	push @tokens, $token;
	last if $token->[0] eq 'END_OF_INPUT';
}
