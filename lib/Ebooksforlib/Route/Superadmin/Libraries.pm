package Ebooksforlib::Route::Superadmin::Libraries;

=head1 Ebooksforlib::Route::Superadmin::Libraries

Routes for handling libraries. 

=cut

use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Dancer::Plugin::Auth::Extensible;
use Dancer::Plugin::FlashMessage;
use Dancer::Exception qw(:all);
use Ebooksforlib::Util;
use Ebooksforlib::Err;

get '/libraries/add' => require_role superadmin => sub { 
    template 'libraries_add';
};

post '/libraries/add' => require_role superadmin => sub {

    unless ( _check_csrftoken( param 'csrftoken' ) ) {
        return redirect '/';
    }

    my $name = param 'name';
    my $realm = param 'realm';
    my $piwik = param 'piwik';
    my $is_consortium = param 'is_consortium';
    try {
        my $hs = HTML::Strip->new();
        $name  = $hs->parse( $name );
        $realm = $hs->parse( $realm );
        $piwik = $hs->parse( $piwik );
        $is_consortium = $hs->parse( $is_consortium );
        $hs->eof;
        my $new_library = rset('Library')->create({
            name  => $name,
            realm => $realm,
            piwik => $piwik,
            is_consortium => $is_consortium,
        });
        flash info => 'A new library was added!';
        redirect '/superadmin';
    } catch {
        flash error => "Oops, we got an error:<br />".errmsg($_);
        error "$_";
        template 'libraries_add', { name => $name };
    };

};

get '/libraries/edit/:id' => require_role superadmin => sub {

    my $id = param 'id';
    my $library = rset('Library')->find( $id );
    template 'libraries_edit', { library => $library };

};

post '/libraries/edit' => require_role superadmin => sub {

    unless ( _check_csrftoken( param 'csrftoken' ) ) {
        return redirect '/';
    }

    my $id    = param 'id';
    my $name  = param 'name';
    my $realm = param 'realm';
    my $piwik = param 'piwik';
    my $is_consortium = param 'is_consortium';
    my $library = rset('Library')->find( $id );
    try {
        my $hs = HTML::Strip->new();
        $name  = $hs->parse( $name );
        $realm = $hs->parse( $realm );
        $piwik = $hs->parse( $piwik );
        $is_consortium = $hs->parse( $is_consortium );
        $hs->eof;
        $library->set_column('name',  $name  );
        $library->set_column('realm', $realm );
        $library->set_column('piwik', $piwik );
        $library->set_column('is_consortium', $is_consortium );
        $library->update;
        flash info => 'A library was updated!';
        redirect '/superadmin';
    } catch {
        flash error => "Oops, we got an error:<br />".errmsg($_);
        error "$_";
        template 'libraries_edit', { library => $library };
    };

};

get '/libraries/delete/:id?' => require_role superadmin => sub { 
    
    # Confirm delete
    my $id = param 'id';
    my $library = rset('Library')->find( $id );
    template 'libraries_delete', { library => $library };
    
};

get '/libraries/delete_ok/:id?' => require_role superadmin => sub { 

    unless ( _check_csrftoken( param 'csrftoken' ) ) {
        return redirect '/';
    }

    # Do the actual delete
    my $id = param 'id';
    my $library = rset('Library')->find( $id );
    # TODO Check that this library is ready to be deleted!
    try {
        $library->delete;
        flash info => 'A library was deleted!';
        info "Deleted library with ID = $id";
        redirect '/superadmin';
    } catch {
        flash error => "Oops, we got an error:<br />".errmsg($_);
        error "$_";
        redirect '/superadmin';
    };
    
};

true;
