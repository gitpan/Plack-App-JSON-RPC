package Plack::App::JSON::RPC::Procedure;
our $VERSION = '0.0100';

=head1 NAME

Plack::App::JSON::RPC::Procedure - The data holder between RPC requests and responses.

=head1 VERSION

version 0.0100

=head1 SYNOPSIS

 use Plack::App::JSON::RPC::Procedure;

 my $proc = Plack::App::JSON::RPC::Procedure->new;

 $proc->error_code(300);

 my $method = $proc->method;

=head1 DESCRIPTION

Something needs to act as an intermediary to hold the data and state of requests coming in, RPC being called, and responses going out. THis module fits that bill.

=cut


use Moose;

#--------------------------------------------------------

=head2 error_code ( [ code ] ) 

Returns the current error code.

=head3 code

An integer. Sets an error code.

=head2 has_error_code ( )

Returns a boolean indicating whether an error code has been set.

=cut

has error_code => (
    is          => 'rw',
    default     => undef,
    predicate   => 'has_error_code',
);

#--------------------------------------------------------

=head2 error_message ( [ message ] ) 

Returns the current error message.

=head3 message

A string. Sets an error message.

=cut

has error_message => (
    is      => 'rw',
    default => undef,
);

#--------------------------------------------------------

=head2 error_data ( [ data ] ) 

Returns the current error data. Error data is entirely defined by the application (e.g. detailed error information, nested errors etc.).

=head3 data

A scalar or reference. Sets an error data.

=cut

has error_data  => (
    is      => 'rw',
    default => undef,
);

#--------------------------------------------------------

=head2 invalid_request ( [ data ] ) 

Sets an Invalid Request error as defined by the JSON-RPC 2.0 spec.

=head3 data 

Optionally set some error data for the error.

=cut

sub invalid_request {
    my ($self, $msg) = @_;
    $self->error_code(-32600);
    $self->error_message('Invalid Request.');
    $self->error_data($msg);
}

#--------------------------------------------------------

=head2 method_not_found ( [ data ] ) 

Sets a Method Not Found error as defined by the JSON-RPC 2.0 spec.

=head3 data 

Optionally set some error data for the error.

=cut

sub method_not_found {
    my ($self, $msg) = @_;
    $self->error_code(-32601);
    $self->error_message('Method not found.');
    $self->error_data($msg);
}

#--------------------------------------------------------

=head2 invalid_params ( [ data ] ) 

Sets an Invalid Params error as defined by the JSON-RPC 2.0 spec.

=head3 data 

Optionally set some error data for the error.

=cut

sub invalid_params {
    my ($self, $msg) = @_;
    $self->error_code(-32602);
    $self->error_message('Invalid params.');
    $self->error_data($msg);
}

#--------------------------------------------------------

=head2 internal_error ( [ data ] ) 

Sets an Internal Error as defined by the JSON-RPC 2.0 spec.

=head3 data 

Optionally set some error data for the error.

=cut

sub internal_error {
    my ($self, $msg) = @_;
    $self->error_code(-32603);
    $self->error_message('Internal error.');
    $self->error_data($msg);
}

#--------------------------------------------------------

=head2 method ( [ name ] ) 

Returns the name of the procedure to be called.

=head3 name

An alphanumeric string. Sets the method name. Will set an error if the method name is not alpha-numeric.

=cut

has method  => (
    is      => 'rw',
    default => undef,
    trigger => sub {
            my ($self, $new, $old) = @_;
            unless ($new =~ m{^[A-Za-z0-9_]+$}xms) {
                $self->invalid_request($new.' is not a valid method name.');
            }
        },
);

#--------------------------------------------------------

=head2 params ( [ data ] ) 

Returns the parameters to be passed into the procedure.

=head3 data

An array or hashref. Sets the parameters.

=cut

has params  => (
    is      => 'rw',
    default => undef,
);

#--------------------------------------------------------

=head2 id ( [ id ] ) 

Returns the id of the request.

=head3 id

Sets the id of the request.

=cut

has id  => (
    is      => 'rw',
    default => undef,
);

#--------------------------------------------------------

=head2 result ( [ data ] ) 

Returns the data that will be sent back to the client.

=head3 data

Sets the data that will be sent back to the client.

=cut

has result => (
    is      => 'rw',
    default => undef,
);

#--------------------------------------------------------

=head2 response ( ) 

Formats the data stored in this object into the data structure expected by L<Plack::App::JSON::RPC>, which will ultimately be returned to the client.

=cut

sub response {
    my ($self) = @_;
    my $error;
    if ($self->has_error_code) {
        $error = {
            code    => $self->error_code,
            message => $self->error_message,
            data    => $self->error_data,
        };
    }
    return { 
        jsonrpc => '2.0',
        id      => $self->id,
        result  => $self->result,
        error   => $error,
    };
}

=head1 LEGAL

Plack::App::JSON::RPC is Copyright 2009 Plain Black Corporation (L<http://www.plainblack.com/>) and is licensed under the same terms as Perl itself.

=cut

no Moose;
__PACKAGE__->meta->make_immutable;