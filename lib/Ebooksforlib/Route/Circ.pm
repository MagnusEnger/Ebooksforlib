package Ebooksforlib::Route::Circ;

=head1 Ebooksforlib::Route::Circ

Routes for handling circulation (borrowinf and returning). 

=cut

use Dancer ':syntax';
use Dancer::Plugin::DBIC;
use Dancer::Plugin::Auth::Extensible;
use Dancer::Plugin::FlashMessage;
use Dancer::Exception qw(:all);

use Ebooksforlib::Util;

get '/borrow/:item_id' => require_login sub {

    my $item_id = param 'item_id';
    my $item = rset('Item')->find( $item_id );
    my $user = rset('User')->find( session('logged_in_user_id') );

    # Check that the user belongs to the same library as the item
    # This should not happen, unless the user is trying to cheat the system
    unless ( $user->belongs_to_library( $item->library_id ) ) {
        flash error => "You are trying to borrow a book from a library you do not belong to!";
        debug '!!! User ' . $user->id . ' tried to borrow item ' . $item->id . ' which does not belong to the users library';
        return redirect '/book/' . $item->file->book_id;
    }
    
    # Check that any item of the book this item belongs to is not already on loan to the user
    if ( _user_has_borrowed( $user, $item->file->book ) ) {
        flash error => "You have already borrowed this book!";
        return redirect '/book/' . $item->file->book_id;
    }

    # Check the number of concurrent loans
    # Users should not see this, unless they try to cheat the system, because the 
    # "Borrow" links should be hidden when they have reached the threshold
    my $library = rset('Library')->find( session('chosen_library') );
    if ( $user->number_of_loans_from_library( $library->id ) == $library->concurrent_loans ) {
        flash error => "You have already reached the number of concurrent loans for your library!";
        debug '!!! User ' . $user->id . ' tried to borrow too many books';
        return redirect '/book/' . $item->file->book_id;
    }
    
    # Calculate the due date/time
    my $dt = DateTime->now( time_zone => setting('time_zone') );
    debug '*** Now: ' . $dt->datetime;
    my $loan_period = DateTime::Duration->new(
        days    => $item->loan_period,
    );
    $dt->add_duration( $loan_period );
    debug '*** Due: ' . $dt->datetime;

    try {
        my $new_loan = rset('Loan')->create({
            item_id    => $item_id,
            user_id    => $user->id,
            library_id => session('chosen_library'),
            due        => $dt,
            gender     => $user->gender,
            age        => _calculate_age( $user->birthday ),
            zipcode    => _munge_zipcode( $user->zipcode ),
        });
        # Log
        _log2db({
            logcode => 'BORROW',
            logmsg  => "item_id: $item_id, due: $dt",
        });
        # flash info => "You borrowed a book!";
        redirect '/book/' . $item->file->book_id;
    } catch {
        flash error => "Oops, we got an error:<br />$_";
        error "$_";
        redirect '/book/' . $item->file->book_id;
    };
};

get '/return/:item_id' => require_login sub {

    my $item_id = param 'item_id';
    my $user_id = session('logged_in_user_id');
    
    my $loan = rset('Loan')->find({ item_id => $item_id, user_id => $user_id });
    
    # DEBUG
    debug $loan->item->loan_period;
    debug $loan->user->name;
    
    my $return = _return_loan( $loan );
    if ( $return->{'error'} == 1 ) {
        debug $return->{'errormsg'};
        flash error => "Sorry, an error occured: " . $return->{'errormsg'};
    } else {
        # Log
        _log2db({
            logcode => 'RETURN',
            logmsg  => "item_id: $item_id",
        });
        debug "*** Returned item for item_id = $item_id, user_id = $user_id";
    }
    return redirect '/my';

};

true;
