package HTML::FormHandler::Model::DBIC::TypeMap;
# ABSTRACT: type mape for DBICFields

use Moose;
use namespace::autoclean;

=head1 SYNOPSIS

Use by L<HTML::FormHandler::TraitFor::DBICFields>.

=cut

has 'data_type_map' => ( is => 'ro', isa => 'HashRef',
   lazy => 1, builder => 'build_data_type_map',
   traits => ['Hash'],
   handles => {
      get_field_type => 'get'
   },
);

sub build_data_type_map {
    my $self = shift;
    return {
        'varchar'   => 'Text',
        'text'      => 'TextArea',
        'integer'   => 'Integer',
        'int'       => 'Integer',
        'mediumint' => 'Integer',
        'numeric'   => 'Integer',
        'datetime'  => 'Text',
        'timestamp' => 'Text',
        'bool'      => 'Boolean',
        'decimal'   => 'Float',
        'bigint'    => 'Integer',
        'enum'      => 'Select',
        'set'       => 'Select',
   };
}

sub type_for_column {
    my ( $self, $info ) = @_;

    my %field_def;
    my $type;
    if( my $def = $info->{extra}->{field_def} ) {
        return $def;
    }
    if( $info->{data_type} ) {
        $type = $self->get_field_type( lc($info->{data_type}) );
    }
    $type ||= 'Text';
    $field_def{type} = $type;
    if( $type eq 'Textarea' && $info->{size} )
	{
    	$field_def{size} = $info->{size}
	}
	elsif( $type eq 'Text' && $info->{size} )
	{
    	$field_def{maxlength} = $info->{size};
   		$field_def{size} = $info->{size} <= 80 ? $info->{size} : 80;
	}
	elsif ( ( $type eq 'Select' or $type eq 'Select' ) && $info->{extra}->{list} )
	{
		$field_def{options} = [ map +{ value => $_, label => $_ }, @{ $info->{extra}->{list} } ];
		if ( lc($info->{data_type}) eq 'set' )
		{
			$field_def{multiple} = 1;
		}
	}
	
    $field_def{required} = 1 if not $info->{is_nullable};
    return \%field_def;
}

# stub
sub type_for_rel {
    my ( $self, $rel ) = @_;
    return;
}

1;
