package PerlX::Generator::Compiler;

use strictures 2;
use re 'eval';
use Filter::Util::Call;
use Module::Compile -base;
use PPR::X;

our $Found_Start;

our @Found;

my $grammar = qr{
  (?(DEFINE)
    (?<PerlCall>
      (?:
        generator
        (?&PerlOWS)
        (?{ local $Found_Start = pos() })
        (?&PerlBlock)
        (?{ push @Found, [ $Found_Start, pos() - $Found_Start ] })
      )
      | (?&PerlStdCall)
    )
  )
  $PPR::X::GRAMMAR
}x;

sub pmc_compile {
  my (undef, $code) = @_;
  local @Found;
  unless ($code =~ /\A (?&PerlDocument) \Z $grammar/x) {
    warn "Failed to parse file; expect complication errors, sorry.\n";
    return undef;
  }
  my $offset = 0;
  my $sym_gen = 'A001';
  foreach my $case (@Found) {
    my ($start, $len) = @$case;
    $start += $offset;
    my $block = substr($code, $start, $len);
    my $new_block = $block;
    $new_block =~ s/^{/{ __gen_resume; / or die "Whither block start?";
    $new_block =~ s{(yield(?&PerlOWS)((?&PerlCommaList)?+)) $grammar}{
      my $gen = '__GEN_'.$sym_gen++;
      "do { __gen_suspend '${gen}', $2; ${gen}: __gen_sent }";
    }xeg;
    substr($code, $start, $len) = $new_block;
    $offset += length($new_block) - $len;
  }
  return $code;
}

1;
