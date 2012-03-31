use strict;
use warnings;
package Chromosome;

my $size = 16;
my @alleles = (0..24);

my @scores_from_root = (3, -2, 3, -2, 3,
                        0, -2, 3, -2, 4, -2, 2);

#class method
sub new {
    my $class = shift;
    bless {
        genes => [],
        score => 0,
    },$class;
}

sub cross{
    my ($class,$a,$b) = @_;

    my $self = __PACKAGE__->new;
    for my $i (0..$size-1) {
        my $from = int(rand(2)) ? $a : $b;
        $self->{genes}->[$i] = $a->genes->[$i]
    }

    return $self;
}

#instatnce method
sub genes {
    shift->{genes};
}
sub score {
    shift->{score};
}

sub random{
    my $self = shift;

    for my $i (0..$size-1) {
        $self->{genes}->[$i] = $alleles[int(rand(scalar @alleles))];
    }
    $self;
}

sub mutation{
    my $self = shift;

    my @genes = @{$self->{genes}};

    my $i = int(rand($size));
    $genes[$i] = $alleles[int(rand(scalar @alleles))];
    $self->{genes} = [@genes];

    $self;
}

sub copy{
    my $self = shift;

    my $ret = __PACKAGE__->new;
    my @genes = @{$self->{genes}};
    $ret->{genes} = [@genes];
    $ret;
}

sub evaluate{
    my ($self, $root_note) = @_;

    # 休符
    my %score_of;
    $score_of{0} = 2;

    my $score_index = $root_note - 1;
    for my $i (1..24) {
        $score_index = 0 if $score_index >= 12;
        $score_of{$i} = $scores_from_root[$score_index];
        $score_index++;
    }

    my $score = 0;
    my $pos = 0;
    for my $gene (@{$self->{genes}}){
        my $by = 1;

        #小説の頭ならば3倍のスコア
        if ($pos == 0) {
            $by = 3;
        }
        #強拍ならば2倍のスコア
        elsif ($pos % 4) {
            $by = 2;
        }

        $score += $score_of{$gene} * $by;
        $pos++;
    }
    $self->{score} = $score;

    $self;
}

1;
