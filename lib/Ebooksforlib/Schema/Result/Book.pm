use utf8;
package Ebooksforlib::Schema::Result::Book;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ebooksforlib::Schema::Result::Book

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<books>

=cut

__PACKAGE__->table("books");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 1
  size: 255

=head2 date

  data_type: 'varchar'
  is_nullable: 0
  size: 32

=head2 isbn

  data_type: 'varchar'
  is_nullable: 1
  size: 64

=head2 pages

  data_type: 'varchar'
  is_nullable: 1
  size: 32

=head2 coverurl

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 coverimg

  data_type: 'mediumblob'
  is_nullable: 1

=head2 dataurl

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 1, size => 255 },
  "date",
  { data_type => "varchar", is_nullable => 0, size => 32 },
  "isbn",
  { data_type => "varchar", is_nullable => 1, size => 64 },
  "pages",
  { data_type => "varchar", is_nullable => 1, size => 32 },
  "coverurl",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "coverimg",
  { data_type => "mediumblob", is_nullable => 1 },
  "dataurl",
  { data_type => "varchar", is_nullable => 1, size => 255 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<isbn>

=over 4

=item * L</isbn>

=back

=cut

__PACKAGE__->add_unique_constraint("isbn", ["isbn"]);

=head1 RELATIONS

=head2 book_creators

Type: has_many

Related object: L<Ebooksforlib::Schema::Result::BookCreator>

=cut

__PACKAGE__->has_many(
  "book_creators",
  "Ebooksforlib::Schema::Result::BookCreator",
  { "foreign.book_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 comments

Type: has_many

Related object: L<Ebooksforlib::Schema::Result::Comment>

=cut

__PACKAGE__->has_many(
  "comments",
  "Ebooksforlib::Schema::Result::Comment",
  { "foreign.book_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 downloads

Type: has_many

Related object: L<Ebooksforlib::Schema::Result::Download>

=cut

__PACKAGE__->has_many(
  "downloads",
  "Ebooksforlib::Schema::Result::Download",
  { "foreign.book_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 files

Type: has_many

Related object: L<Ebooksforlib::Schema::Result::File>

=cut

__PACKAGE__->has_many(
  "files",
  "Ebooksforlib::Schema::Result::File",
  { "foreign.book_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 list_books

Type: has_many

Related object: L<Ebooksforlib::Schema::Result::ListBook>

=cut

__PACKAGE__->has_many(
  "list_books",
  "Ebooksforlib::Schema::Result::ListBook",
  { "foreign.book_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 old_downloads

Type: has_many

Related object: L<Ebooksforlib::Schema::Result::OldDownload>

=cut

__PACKAGE__->has_many(
  "old_downloads",
  "Ebooksforlib::Schema::Result::OldDownload",
  { "foreign.book_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 ratings

Type: has_many

Related object: L<Ebooksforlib::Schema::Result::Rating>

=cut

__PACKAGE__->has_many(
  "ratings",
  "Ebooksforlib::Schema::Result::Rating",
  { "foreign.book_id" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 creators

Type: many_to_many

Composing rels: L</book_creators> -> creator

=cut

__PACKAGE__->many_to_many("creators", "book_creators", "creator");


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-09-26 15:15:41
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:6fbkWQSI7WSZhQBmnrUpxg

use Ebooksforlib::Util;

__PACKAGE__->many_to_many( lists => 'list_books', 'list' );

__PACKAGE__->many_to_many( libraries => 'items', 'library' );

sub creators_as_string {
    my $self = shift;
    my $creator = '';
    my $counter = 0;
    foreach my $c ( $self->creators ) {
        if ( $counter > 0 ) {
            $creator .= '; ';
        }
        $creator .= $c->name;
        $counter++;
    }
    return $creator;
}

sub get_rating_from_user {
    my ( $self, $user_id ) = @_;
    my @ratings = $self->ratings;
    my $num_ratings = @ratings;
    if ( $num_ratings > 0 ) {
        foreach my $rating ( $self->ratings ) {
            if ( $rating && $rating->user_id == $user_id ) {
                return $rating->rating;
            }
        }
    }
    return 0;
}

sub get_avg_rating {

    my ( $self ) = @_;
    
    # http://search.cpan.org/~ribasushi/DBIx-Class-0.08250/lib/DBIx/Class/ResultSetColumn.pm
    # http://search.cpan.org/~ribasushi/DBIx-Class-0.08250/lib/DBIx/Class/Manual/Cookbook.pod#Getting_Columns_Of_Data
    # FIXME This gives an error that rset is unknown 
    # my $rs = rset('Rating')->search({ book_id => $self->id });
    # my $rs_column = $rs->get_column('rating');
    # return $rs_column->func('AVG'); 
    
    my $sum = 0;
    my $count = 0;
    my $average = 0;
    
    foreach my $rating ( $self->ratings ) {
        $sum = $sum + $rating->rating;
        if ( $rating->rating > 0 ) {
            $count++;
        }
    }

    if ( $count > 0 ) {
        $average = sprintf "%.1f", $sum / $count;
    }

    return { 'average' => $average, 'votes' => $count };

}

sub get_descriptions {

    my ( $self ) = @_;

    if ( $self->dataurl ) {
        my $sparql = 'SELECT DISTINCT ?krydder ?abstract WHERE {
                          OPTIONAL { <' . $self->dataurl . '> <http://data.deichman.no/krydder_beskrivelse> ?krydder . }
                          OPTIONAL { <' . $self->dataurl . '> <http://purl.org/dc/terms/abstract> ?abstract . }
                      }';
        my $descriptions = _sparql2data( $sparql );
        # debug "*** Descriptions: " . Dumper $descriptions;
        # if ( $descriptions->{'error'} ) {
        #     error $descriptions->{'error'};
        #     flash error => "Sorry, unable to display descriptions (" . $descriptions->{'error'} . ")";
        # }
        return $descriptions;
    }
    return;

}

1;
