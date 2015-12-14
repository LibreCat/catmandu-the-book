use v5.14;
use Catmandu -all, -load;
use Pandoc::Elements;
use Pod::Simple::Pandoc;

my $modules = importer('JSON', multiline => 1, file => 'modules.json')->first;

# Foo::Bar::Doz => foo-bar-doz
sub module2id {
    lc( join '-', split '::', shift );
}

my $sections = [];
foreach my $type (qw(Importer Exporter Store)) {
    push @$sections, Header 1, attributes { id => $type }, [ Str $type ];

    # start with core modules only
#    my @mods = grep { $_->{distribution} eq 'Catmandu' } @{$modules->{$type}};
    my @mods = @{$modules->{$type}};

    foreach my $m ( @mods ) {
        push @$sections, 
            Header 2, attributes { id => module2id($m->{module}) }, 
                [ Str $m->{name} ];
        my $name = $m->{module};
        my $file = "$name.pm";
        $file =~ s!::!/!g;

        my $pod = Pod::Simple::Pandoc->new->parse_file("download/lib/$file");

        # remove sections
        my $skip = 0;
        $pod->transform( sub {
            my $e = shift;

            if ($skip) {
                if ($e->name eq 'Header' and $e->level <= $skip) {
                    $skip = 0;
                } else {
                    return [];
                }
            }
            if ($e->name eq 'Header' and $e->string !~ /SYNOPSIS/) {
                $skip = $e->level;
                return [];
            } elsif ($e->name eq 'Header') {
                return [];
            }
            return # keep
        } );

        # push two levels down
        $pod->transform( 
            Header => sub {
                Header $_->level+2, $_->attr, $_->content;
            },
        );

        # modify links
        $pod->transform(
            Link => sub {
                return if $_->url !~ qr{https://metacpan.org/pod/(Catmandu.*)$};
                Link $_->content, [ "#".module2id($1), $_->title ];
            }
        );

        
        push @$sections, @{$pod->content};
    }
}

my $doc = Document {
    title => MetaInlines [ Str 'Catmandu - the book' ], 
}, $sections;
print $doc->to_json;
