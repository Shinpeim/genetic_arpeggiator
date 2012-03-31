package Renderer;
use strict;
use warnings;
use Sound::NeSynth;

my %tones = ();
my %patterns = ();
my %tone_of = (
    0 => "",
    1 => "C3", 2 => "C+3", 3 => "D3", 4 => "D+3", 5 => "E3",
    6 => "F3", 7 => "F+3", 8 => "G3", 9 => "G+3", 10 => "A3", 11 => "A+3", 12 => "B3",
    13 => "C4", 14 => "C+4", 15 => "D4", 16 => "D+4", 17 => "E4",
    18 => "F4", 19 => "F+4", 20 => "G4", 21 => "G+4", 22 => "A4", 23 => "A+4", 24 => "B4",
);

for my $note ( qw/C3 C+3 D3 D+3 E3  F3 F+3 G3 G+3 A3 A+3 B3
                  C4 C+4 D4 D+4 E4  F4 F+4 G4 G+4 A4 A+4 B4/ ) {
    $tones{$note} = +{
        osc => {
            freq => Sound::NeSynth::note_to_freq( $note ),
            waveform => 'pulse',
            mod => { speed => 0.25, depth => 0, waveform => 'env', curve => 1.8 }
        },
        amp => { sec => 0.25, waveform => 'env', curve => 1.4 }
    };
}

sub new{
    my $class = shift;
    my %patterns;
    for my $note ( qw/C3 C+3 D3 D+3 E3  F3 F+3 G3 G+3 A3 A+3 B3
                      C4 C+4 D4 D+4 E4  F4 F+4 G4 G+4 A4 A+4 B4/ ) {
        $patterns{$note} = [];
    }
    bless {
        patterns => \%patterns,
    },$class;
}

sub add{
    my ($self,$index) = @_;
    my $note_to_play = $tone_of{$index};

    for my $note ( qw/C3 C+3 D3 D+3 E3  F3 F+3 G3 G+3 A3 A+3 B3
                      C4 C+4 D4 D+4 E4  F4 F+4 G4 G+4 A4 A+4 B4/ ) {
        push @{$self->{patterns}->{$note}}, $note eq $note_to_play ? 1 : 0;
    }
}

sub render{
    my ($self,$name) = @_;
    my @beats;
    for my $tone ( qw/C3 C+3 D3 D+3 E3  F3 F+3 G3 G+3 A3 A+3 B3
                      C4 C+4 D4 D+4 E4  F4 F+4 G4 G+4 A4 A+4 B4/ ) {
        if (grep {$_ == 1} @{$self->{patterns}->{$tone}} ) {
            push @beats, { seq => $self->{patterns}->{$tone},  tone => $tones{$tone},  vol => 1.00 };
        }
    }

    my $synth = Sound::NeSynth->new();
    $synth->render({
        bpm => 138, # beats per minute
        beats => [@beats]
    });

    $synth->write("$name.wav");
}
1;
