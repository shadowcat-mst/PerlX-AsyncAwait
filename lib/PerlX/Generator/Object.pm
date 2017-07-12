package PerlX::Generator::Object;

use strictures 2;
use Lexical::Context;
use PerlX::Generator::Invocation;
use Moo;

has code => (is => 'ro', required => 1);

has lexical_context => (is => 'lazy', builder => sub {
  my ($self) = @_;
  return Lexical::Context->new(code => $self->code);
});

sub start {
  my ($self, @args) = @_;
  return PerlX::Generator::Invocation->new(
    code => $self->code,
    lexical_context => $self->lexical_context,
    start_args => \@args
  );
}

1;
