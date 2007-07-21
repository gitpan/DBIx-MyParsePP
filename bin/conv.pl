#
# This script opens certain files from the MySQL and converts them to Perl modules
#

use strict;
use Data::Dumper;

my $orig_file = 'mysql/sql_yacc.yy';
my $new_file = 'myparsepp.yy';
open (ORIG, "$orig_file") or die $!;
read (ORIG, my $orig, -s $orig_file);

# $fix missing ; in opt_profile_defs: rule 
$orig =~ s{\| profile_defs\n}{| profile_defs;\n\n}sgio;
$orig =~ s{',' profile_def\n}{',' profile_def;\n\n}sgio;

# FIXME, remove %prec from JOIN

$orig =~ s{table_ref \%prec TABLE_REF_PRIORITY}{table_ref TABLE_REF_PRIORITY}sgio;

$orig =~ s|%{.*?%}||sgio;

my ($first, $second, $third) = split ("%%\n", $orig);

my ($expect) = $first =~ m{(%expect .*?)[\r\n]}sio;
my @lefts = $first =~ m{(%left[\s\t]*.*?)[\r\n]}gio;
my @rights = $first =~ m{(%right[\s\t]*.*?)[\r\n]}gio;

my $new_prologue = "$expect\n".join("\n",@lefts)."\n".join("\n", @rights);

foreach my $q (1..20) {
	$second =~ s|[^']{[^{}]*?}||sgio;
}

$second =~ s{/\*.*?\*/}{}sgio;

my @new_rules;

my @orig_rules = $second =~ m{([A-z0-9_]*?):(.*?);[^'"]}sgio;

while (my ($rule_name, $rule_body) = splice(@orig_rules, 0, 2)) {
	$rule_body =~ s{[\r\n]}{}sgio;
	my @parts = split(m{[^'"]\|}sio, $rule_body);
	my @new_parts;

	@parts = ('') if ($#parts == -1);

	foreach my $part (@parts) {
		my $new_part =  $part.' { bless(["'.$rule_name.'", @_[1..$#_] ], "DBIx::MyParsePP::Rule") } ';
		push @new_parts, $new_part;
	}

	my $new_rule = "$rule_name:\n".join("\n|", @new_parts).";\n\n";
	push @new_rules, $new_rule;
};

my $new_rules = join("\n", @new_rules);

my $new_epilogue;

my $new = join("\n%%\n", $new_prologue, $new_rules, $new_epilogue);

open (NEW, ">$new_file") or die $!;
print NEW $new;
system(my $line = "yapp -m MyParser -m DBIx::MyParsePP::Parser -o lib/DBIx/MyParsePP/Parser.pm $new_file");
print "$line\n";


my $lex_header_name = 'mysql/lex.h';
open (LEX_HEADER_FILE, $lex_header_name);
read (LEX_HEADER_FILE, my $lex_header, -s $lex_header_name);

my %symbols;
my ($symbols) = $lex_header =~ m/symbols\[\] = {(.*?)};/sgio;
my @symbols = split('},', $symbols);
foreach my $symbol (@symbols) {
	my ($keyword, $symbol) = $symbol =~ m{"(.*?)",.*?SYM\((.*?)\)}sio;
	$symbols{$keyword} = $symbol;
}

my %functions;
my ($functions) = $lex_header =~ m/sql_functions\[\] = {(.*?)};/sgio;
my @functions = split('},', $functions);

foreach my $function (@functions) {
        my ($keyword, $symbol) = $function =~ m{"(.*?)",.*?SYM\((.*?)\)}sio;
	$functions{$keyword} = $symbol;
}

my $symbol_pm = 'lib/DBIx/MyParsePP/Symbols.pm';

open (SYMBOL_MODULE, '>'.$symbol_pm) or die "unable to open $symbol_pm: $!";
print SYMBOL_MODULE "package DBIx::MyParsePP::Symbols;\n1;\n";
print SYMBOL_MODULE Data::Dumper->Dump([\%symbols, \%functions], [qw(symbols functions)]);
print SYMBOL_MODULE "\n1;\n";


# ==================== Character Sets ==============================

my $charset_file = 'mysql/Index.xml';
open (CHARSET_FILE, $charset_file) or die "unable to open $charset_file: $!";
read (CHARSET_FILE, my $charset_xml, -s $charset_file);

my @names = $charset_xml=~ m{<charset name="(.*?)">}sgio;
my @aliases = $charset_xml =~ m{<alias>(.*?)</alias>}sgio;

my @charsets = (@names, @aliases);
my %charsets;
map { $charsets{$_} = $_ } @charsets;	# Convert array into hash

my $charset_pm = 'lib/DBIx/MyParsePP/Charsets.pm';

open (CHARSET_MODULE, '>'.$charset_pm) or die "unable to open $charset_pm: $!";
print CHARSET_MODULE "package DBIx::MyParsePP::Charsets;\n1;\n";
print CHARSET_MODULE Data::Dumper->Dump([\%charsets], [qw(charsets)]);
print CHARSET_MODULE "\n1;\n";

# ==================== Characters ===================================

my $char_file = 'mysql/ascii.xml';
open (CHAR_FILE, $char_file) or die "unable to open $char_file: $!";
read (CHAR_FILE, my $char_xml, -s $char_file);

my ($xml_part) = $char_xml =~ m{<charset name="ascii">(.*?)</charset>}sgio;
my ($ctype_part) = $xml_part =~ m{<ctype>(.*?)</ctype>}sgio;
my ($map) = $ctype_part =~ m{<map>(.*?)</map>}sgio;

my @raw_map = $map =~ m{[0-9A-F]{2}}sgio;
my @ctype = map { hex($_) } @raw_map;

my $char_pm = 'lib/DBIx/MyParsePP/Ascii.pm';

open (CHAR_MODULE, '>'.$char_pm) or die "unable to open $char_pm: $!";
print CHAR_MODULE "package DBIx::MyParsePP::Ascii;\n1;\n";
print CHAR_MODULE Data::Dumper->Dump([\@ctype], [qw(ctype)]);
print CHAR_MODULE "\n1;\n";
