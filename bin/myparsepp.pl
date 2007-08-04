use strict;
use DBIx::MyParsePP;
use DBIx::MyParsePP::Rule;
use DBIx::MyParsePP::Token;
use Data::Dumper;

my $parser = DBIx::MyParsePP->new();

print "query is |$ARGV[0]|\n";
my $query = $parser->parse($ARGV[0]);
print Dumper $query;
print "Result is ".$query->toString()."\n";
