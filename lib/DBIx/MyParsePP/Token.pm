package DBIx::MyParsePP::Token;

1;

sub toString {
	my $token = shift;
	if ($token->[0] eq 'TEXT_STRING') {
		return "'".$token->[1]."'";
	} elsif ($token->[0] eq 'UNDERSCORE_CHARSET') {
		return '_'.$token->[1];
	} else {
		return $token->[1];
	}
}

1;
