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
sub download($);
sub extract_id($);
sub show_usage();
sub debug($);

my %o =(
    'file'=>'',
    'id'=>'',
);

GetOptions(\%o,
    'file=s',
    'id=s',
    'help',
    'debug',
) or $o{'help'}++;

show_usage() if $o{'help'} || (!$o{'id'} && !$o{'file'});

if ($o{'id'}) {
    my $youtube = YouTube->new(id=>$o{'id'});
    foreach my $url (@{$youtube->getdata()}) {
        download($url);
    }
}

if ($o{'file'}) {
    open LF, "< " . $o{'file'} || die 'file not open :$!\n';
    while (<LF>) {
        chomp $_;
        download($_);
    }
    close LF;
}

sub download($) {
    my $url = shift;
    my $id = extract_id($url);

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

sub extract_id($) {
    my $id = shift;

    debug('URL:' . $id);
    $id =~ s/.*v=(.*)&*.*/$1/g;          # http://www.youtube.com/watch?v=XXXXXXXX&amp;feature=youtube_gdata
    $id =~ s/.*\/v\/(.*)&*.*/$1/g;       # http://www.youtube.com/v/XXXXXXXX&hl=ja_JP&fs=1&
    $id =~ s/^\-/@/;
    debug('ID :' . $id);

    return $id;
}

sub show_usage() {
    print <<"EOD";

Usage: perl $0 [Options]

 Options:
   --id   userid        YouTube User ID
   --file filename      YouTube List File Name
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
