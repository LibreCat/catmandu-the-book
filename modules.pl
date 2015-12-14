use v5.14;
use Catmandu -all, -load;

my $modules = { };

importer('default', file => 'distributions.json')->each(sub {
    my $distr = shift;
    foreach (@{$distr->{provides}}) {
        next unless /^Catmandu::(Importer|Exporter|Store|Fix)::([^:]+)$/;
        my ($ns, $name) = ($1, $2);
        push @{$modules->{$ns}}, {
            name         => $name,
            module       => "Catmandu::${ns}::$name",
            distribution => $distr->{name},
        };
    }
});

foreach my $ns ( keys %$modules ) {
    $modules->{$ns} = [
        sort { $_->{name} cmp $_->{name} } @{ $modules->{$ns} } 
    ]
}

exporter('default', file => 'modules.json')->add($modules);

