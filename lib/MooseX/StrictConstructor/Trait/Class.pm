package MooseX::StrictConstructor::Trait::Class;
BEGIN {
  $MooseX::StrictConstructor::Trait::Class::VERSION = '0.13';
}

use Moose::Role;

use namespace::autoclean;

use B ();
use Carp ();

around '_inline_BUILDALL' => sub {
    my $orig = shift;
    my $self = shift;

    my @source = $self->$orig();

    my @attrs = (
        '__INSTANCE__ => 1,',
        map { B::perlstring($_) . ' => 1,' }
        grep {defined}
        map  { $_->init_arg() } $self->get_all_attributes()
    );

    return (
        @source,
        'my %attrs = (' . ( join ' ', @attrs ) . ');',
        'my @bad = sort grep { !$attrs{$_} } keys %{ $params };',
        'if (@bad) {',
            'Carp::confess "Found unknown attribute(s) passed to the constructor: @bad";',
        '}',
    );
};

1;

# ABSTRACT: A role to make immutable constructors strict



=pod

=head1 NAME

MooseX::StrictConstructor::Trait::Class - A role to make immutable constructors strict

=head1 VERSION

version 0.13

=head1 DESCRIPTION

This role simply wraps C<_inline_BUILDALL()> (from
C<Moose::Meta::Class>) so that immutable classes have a
strict constructor.

=head1 AUTHOR

Dave Rolsky <autarch@urth.org>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2010 by Dave Rolsky.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut


__END__
