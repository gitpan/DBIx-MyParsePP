package DBIx::MyParsePP;

use DBIx::MyParsePP::Lexer;
use DBIx::MyParsePP::Parser;
use DBIx::MyParsePP::Token;
use DBIx::MyParsePP::Rule;

our $VERSION = '0.25';

use constant MYPARSEPP_YAPP	=> 0;

sub new {
	my $class = shift;
	my $parser = bless ([], $class );
	my $yapp = DBIx::MyParsePP::Parser->new();
	$parser->[MYPARSEPP_YAPP] = $yapp;
	return $parser;
}

sub parse {
	my ($parser, $string) = @_;

	my $lexer = DBIx::MyParsePP::Lexer->new($string);
	my $yapp = $parser->[MYPARSEPP_YAPP];
	
	my $result = $yapp->YYParse( yylex => sub { $lexer->yylex() } );

	if (defined $result) {
		return $result->[0];
	} else {
		return undef;
	}
}

1;

__END__

=head1 NAME

DBIx::MyParsePP - Pure-perl SQL parser based on MySQL grammar and lexer

=head1 SYNOPSIS

  use DBIx::MyParsePP;
  use Data::Dumper;

  my $parser = DBIx::MyParsePP->new();

  my $result = $parser->parse("SELECT 1");

  print Dumper $result;
  print $result->asString();

=head1 DESCRIPTION

C<DBIx::MyParsePP> is a pure-perl SQL parser that implements the MySQL grammar and lexer.
The grammar was converted from the original sql_yacc.yy file by removing all the
C code. The lexer comes from sql_lex.cc, completely translated in Perl almost verbatim.

The grammar is converted into Perl form using L<Parse::Yapp>.

=head1 METHODS

C<DBIx::MyParsePP> provides a single method, C<parse()> which takes the string to be parsed.
The result is either C<undef> if the string can not be parsed, or a L<DBIx::MyParsePP::Rule>
object that contains all nested grammar elements inside it. Within that tree, terminal symbols
are returned as L<DBIx::MyParsePP::Token> objects.

Queries can be reconstructed back into SQL by calling the C<asString()> method of the top-level
L<DBIx:MyParsePP::Rule> object.

=head1 SPECIAL CONSIDERATIONS

The file containing the grammar C<lib/DBIx/MyParsePP/Parser.pm> is about 5 megabytes in size
and takes a while to load. Compex statements take a while to parse, e.g. the first Twins query
from the MySQL manual can only be parsed at a speed of few queries per second per 1GHz of CPU. If
you require a full-speed parsing solution, please take a look at L<DBIx::MyParse>, which requires
a GCC compiler and produces more concise parse trees.

The parse trees produced by C<DBIx::MyParsePP> contain one leaf for every grammar rule that has been
matched, even rules that serve no useful purpose. Therefore, parsing event simple statements such
as C<SELECT 1> produce trees dozens of levels deep. Please exercise caution when walking those trees
recursively.

=head1 SEE ALSO

For Yacc grammars, please see the Bison manual at:

	http://www.gnu.org/software/bison

For generating Yacc parsers in Perl, please see:

	http://search.cpan.org/~fdesar

For a full-speed C++-based parser that generates nicer parse trees, please see L<DBIx::MyParse>

=head1 AUTHOR

Philip Stoev, E<lt>philip@stoev.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007 by Philip Stoev

This library is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public Licence as specified in
the README and LICENCE files.

Please note that this module contains code copyright by MySQL AB released under
the GNU General Public Licence, and not the GNU Lesser General Public Licence.
Using this code for commercial purposes may require purchasing a licence from MySQL AB.

=cut
