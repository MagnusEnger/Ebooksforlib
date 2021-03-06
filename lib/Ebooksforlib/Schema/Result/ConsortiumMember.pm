use utf8;
package Ebooksforlib::Schema::Result::ConsortiumMember;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Ebooksforlib::Schema::Result::ConsortiumMember

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

=head1 TABLE: C<consortium_members>

=cut

__PACKAGE__->table("consortium_members");

=head1 ACCESSORS

=head2 consortium_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 library_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "consortium_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "library_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</consortium_id>

=item * L</library_id>

=back

=cut

__PACKAGE__->set_primary_key("consortium_id", "library_id");

=head1 RELATIONS

=head2 consortium

Type: belongs_to

Related object: L<Ebooksforlib::Schema::Result::Library>

=cut

__PACKAGE__->belongs_to(
  "consortium",
  "Ebooksforlib::Schema::Result::Library",
  { id => "consortium_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);

=head2 library

Type: belongs_to

Related object: L<Ebooksforlib::Schema::Result::Library>

=cut

__PACKAGE__->belongs_to(
  "library",
  "Ebooksforlib::Schema::Result::Library",
  { id => "library_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "RESTRICT" },
);


# Created by DBIx::Class::Schema::Loader v0.07039 @ 2014-10-10 11:19:33
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:wXtAhw5bVXSS5E0j+tKUTQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
