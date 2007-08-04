use strict;

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl simple.t'

#########################

use Test::More tests => 11;

BEGIN { use_ok('DBIx::MyParsePP') };
BEGIN { use_ok('DBIx::MyParsePP::Rule') };
BEGIN { use_ok('DBIx::MyParsePP::Token') };

my $rule_class = 'DBIx::MyParsePP::Rule';
my $token_class = 'DBIx::MyParsePP::Token';

my $myparse = DBIx::MyParsePP->new();

my $query = $myparse->parse("SELECT 1");
ok(defined $query, 'simple1');

ok(ref($query) eq $rule_class,'simple2');
ok($query->name() eq 'query','simple3');

my @arguments = $query->arguments();
ok(ref($arguments[0]) eq $rule_class,'simple4');
ok($arguments[0]->name() eq 'verb_clause', 'simple5');

ok(ref($arguments[1]) eq $token_class,'simple6');
ok($arguments[1]->type() eq 'END_OF_INPUT', 'simple7');

ok([[[$query->arguments()]->[0]->arguments()]->[0]->arguments()]->[0]->name() eq 'select', 'simple8');
