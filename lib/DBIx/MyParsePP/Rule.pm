package DBIx::MyParsePP::Rule;

1;


sub toString {
	my $rule = shift;

	if ($#{$rule} > -1) {
		return join(' ', map {
			$rule->[$_]->toString();	
		} (1..$#{$rule}) );
	} else {
		return undef;
	}
}


1;
