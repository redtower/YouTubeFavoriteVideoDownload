package YouTube;

use strict;
use warnings;
use Moose;
use XML::Simple;
use LWP::Simple;
use Encode;
use Data::Dumper;

sub parse($);
sub show_usage();

has id       => (is => 'rw', isa => 'Str');

sub getdata {
    my $self = shift;
    my $content = getxml($self->{'id'});
    return parse($content);
}

sub parse($) {
    my ($content) = @_;
    my @results;

    my $tree = XMLin(Encode::encode('utf-8', $content));
    foreach my $key ( keys(%{$tree->{'entry'}}) ) {
        my $link = $tree->{'entry'}->{$key}->{'link'}[0]->{'href'};

        push(@results, $link);
    }

    return \@results;
}

sub getxml($) {
    my ($id) = @_;
    my $url = 'http://gdata.youtube.com/feeds/api/users/' . $id . '/favorites?orderby=updated';

    my $dt = LWP::Simple::get($url);

    return $dt;
}
1;

package Main;
use strict;
use warnings;
use Getopt::Long;
sub show_usage();
sub debug($);

my %o =(
    'id'=>'',
);

GetOptions(\%o,
    'id=s',
    'help',
    'debug',
) or $o{'help'}++;

show_usage() if $o{'help'} || !$o{'id'};

my $youtube = YouTube->new(id=>$o{'id'});
foreach my $url (@{$youtube->getdata()}) {
    my $id = $url;
    $id =~ s/.*v=(.*)&.*/$1/g;

    system("grep '$id' id.cfg > /dev/null 2>/dev/null");
    if ($?) {
        my $cmd = 'python youtube-dl/youtube-dl -q -w -t "' . $url . '"';
        debug($url);
        system($cmd);

        open ID, ">> id.cfg";
        print ID $id . "\n";
        close ID;
    }
}

sub show_usage() {
    print <<"EOD";

Usage: perl $0 [Options]

 Options:
   --id userid          YouTube User ID
   --help               Show this message.
EOD
    exit;
}

sub debug($) {
    my $word = shift;
    if ($o{'debug'}) {
        print $word . "\n";
    }
}
exit;
