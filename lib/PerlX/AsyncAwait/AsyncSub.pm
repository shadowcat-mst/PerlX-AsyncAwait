package PerlX::AsyncAwait::AsyncSub;

use strictures 2;
use PerlX::AsyncAwait::Invocation;
use Moo;

extends 'PerlX::Generator::Object';

sub invocation_class { 'PerlX::AsyncAwait::Invocation' }

has invocation_futures => (is => 'ro', default => sub { {} });

around start => sub {
  my ($orig, $self, @args) = @_;
  my $inv = $self->$orig(@args)->step;
  my $f = $inv->completion_future;
  return $f if $f->is_ready;
  (my $if = $self->invocation_futures)->{$f} = $inv;
  my $key = "$f";
  $f->on_ready(sub { my ($if, $key) = @_; sub { delete $if->{$key} } }->($if, $key));
  return $f;
};

1;
