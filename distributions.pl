use v5.14;
use Catmandu -all, -load;
use LWP::Simple;
use HTTP::Status 'status_message';
use File::Path qw(make_path remove_tree);

# get all Catmandu distributions from CPAN, sorted by name
my $distributions = [
    sort { $a->{name} cmp $b->{name} }
    @{ importer('distributions')->to_array }
];

export( $distributions, 'default', 
    array => 1, file => 'distributions.json' );

# download distributions and unpack all modules
remove_tree 'download/lib';
make_path 'download/lib';

foreach my $d (@$distributions) {
    my $full = $d->{name} . '-' . $d->{version};
    my $file = 'download/'.$d->{name}.'.tar.gz';
    say "$full - " . status_message(my $rc = mirror($d->{download_url}, $file));
    if (is_success($rc) or $rc == RC_NOT_MODIFIED) {
        system 'tar', 'xzf', $file, '-C', 'download', "$full/lib";
        system "cp -r download/$full/lib/* download/lib";
        remove_tree "download/$full";
    }
}

