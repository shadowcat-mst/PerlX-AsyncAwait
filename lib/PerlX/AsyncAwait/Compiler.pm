package PerlX::AsyncAwait::Compiler;

use strictures 2;
use base qw(PerlX::Generator::Compiler);

sub top_keyword { 'async' }
sub yield_keyword { 'await' }

1;
