package DBIx::MyParsePP::Rule;

1;

use constant RULE_NAME	=> 0;

sub new {
	my $class = shift;
	my $rule = bless (@_, $class);
	return $rule;
}

sub getName {
	return $_[0]->[RULE_NAME];
}

sub name {
	return $_[0]->[RULE_NAME];
}

sub arguments {
	my @rule = @{$_[0]};
	return @rule[1..$#rule];
}

sub getArguments {
	my @rule = @{$_[0]};
	return @rule[1..$#rule];
}

sub toString {
	my $rule = shift;

	if ($#{$rule} > -1) {
		return join('', map {
			$rule->[$_]->toString();	
		} (1..$#{$rule}) );
	} else {
		return undef;
	}
}

sub print {
	return $_[0]->toString();
}

1;

__END__

=pod

=head1 NAME

DBIx::MyParsePP::Rule - Access individual elements from the DBIx::MyParsePP parse tree

=head1 SYNOPSIS

	use DBIx::MyParsePP;
	use DBIx::MyParsePP::Rule;

	my $parser = DBIx::MyParsePP->new();

	my $query = $parser->parse("SELECT 1");	# $query is a DBIx::MyParsePP::Rule object
	print $query->name();			# prints 'query', the top-level grammar rule

	my @arguments = $query->arguments();	#
	print $arguments[0]->name();		# prints 'verb_clause', the second-level rule

	print ref($arguments[1]);		# prints 'DBIx::MyParsePP::Token'
	print $arguments[1]->type();		# prints END_OF_INPUT

	print [[[$query->arguments()]->[0]->arguments()]->[0]->arguments()]->[0]->name(); # Prints 'select'

=head1 DESCRIPTION

L<DBIx::MyParsePP> uses the C<sql_yacc.yy> grammar from the MySQL source to parse SQL strings. A
parse tree is produced which contains one branch for every rule encountered during parsing. This means
that very deep trees can be produced where only certain branches are important.

=head1 METHODS

C<new($rule_name, @arguments)> constructs a new rule

C<name()> and C<getName()> returns the name of the rule

C<arguments()> and C<getArguments()> return (as array) the right-side items that were matched for that rule

C<asString()> converts the parse tree back into SQL by walking the tree and gathering all tokens in sequence.

=cut


