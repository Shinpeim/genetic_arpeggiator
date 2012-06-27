use strict;
use warnings;
use FindBin;
use List::Util;
use lib "$FindBin::RealBin/lib";
use Chromosome;
use Renderer;

my $format = shift or die "usage: $0 <format> [<bars>]";
my $bars = shift || 82;

die "invalid format, format must be wave or text" unless grep {$_ eq $format} (qw/wave text/);

my $population_size = 100; #集団のサイズ
my $survive_size = 50; # 選択、交叉に関わらず残す染色体のサイズ
my $mutation_rate = 5; # / 100

my $root = 1; #rootはC

my $current_chromosomes = [];
my $chromosomes_to_play = [];

#初期集団作る
{
    for my $i (0..$population_size-1) {
        push @$current_chromosomes, Chromosome->new->random;
    }
}

for (1..$bars) {
    #評価する
    {
        for my $c (@$current_chromosomes){
            $c->evaluate($root);
        }
        #ランダムで一個,個体を演奏用に残す
        push @$chromosomes_to_play,$current_chromosomes->[int rand(scalar @$current_chromosomes)];
    }

    #選択,交叉する
    my $children = [];
    {
        #残す
        my $num = $survive_size;
        for my $i (0..$num-1) {
            push @$children, $current_chromosomes->[$i]->copy;
        }

        #ルーレットつくる
        $current_chromosomes = [sort {$b->score <=> $a->score} @$current_chromosomes];
        my $roulet = [];
        for my $i (0..($population_size - 1)) {
            my $c = $current_chromosomes->[$i];
            my $score = $c->score * 2.0;
            $score = 1 if $score <= 0;
            for my $i (1..$score) {
                push @$roulet, $c;
            }
        }

        #集団サイズの数になるまで交叉して子供を生む
        for my $i ($num..$population_size-1) {
            my $a = $roulet->[int(rand (scalar @$roulet))];
            my $b = $roulet->[int(rand (scalar @$roulet))];

            push @$children, Chromosome->cross($a,$b);
        }
    }

    #変異する
    {
        for my $i (0..$population_size-1) {
            if (int(rand(100)) < $mutation_rate) {
                $children->[$i] = $children->[$i]->mutation;
            }
        }
    }

    #世代交代
    @$current_chromosomes = List::Util::shuffle(@$children);
}

#レンダリング
my $r = Renderer->new;
if ($format eq "wave") {
    for my $c (reverse @$chromosomes_to_play){
        for my $gene (@{$c->genes}) {
            $r->add($gene);
        }
    }
    $r->render("../entropy_enhancement");
}

if ($format eq "text") {
    my $tone_of = {
        0 => "NULL",
        1 => "C3", 2 => "C+3", 3 => "D3", 4 => "D+3", 5 => "E3",
        6 => "F3", 7 => "F+3", 8 => "G3", 9 => "G+3", 10 => "A3", 11 => "A+3", 12 => "B3",
        13 => "C4", 14 => "C+4", 15 => "D4", 16 => "D+4", 17 => "E4",
        18 => "F4", 19 => "F+4", 20 => "G4", 21 => "G+4", 22 => "A4", 23 => "A+4", 24 => "B4",
    };
    for my $c (@$chromosomes_to_play){
        my $tones = [map {sprintf("%4s",$tone_of->{$_})} @{$c->genes}];

        print join(",",@$tones);
        print "\n";
    }
}
