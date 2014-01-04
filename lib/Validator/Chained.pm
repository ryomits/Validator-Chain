package Validator::Chained;
use strict;
use warnings;
use Encode qw/decode_utf8/;
use Time::Piece;
use Carp qw/croak/;

sub new {
	my $class = shift;
	return bless {errors => []}, $class;
}

sub check {
	my ($self, $str, $msg) = @_;

	$self->{str} = $str // '';
	if (ref $msg) {
		$self->{msgs} = $msg;
		$self->{msg} = undef;
	}
	else {
		$self->{msgs} = {};
		$self->{msg} = $msg;
	}
	return $self;
}

sub error {
	my ($self, $msg) = @_;

	my $e = Validator::Chained::Exception->new;
	$e->message($msg);
	croak $e;
}

sub trim {
	my $self = shift;

	$self->{str} =~ s/^\s+//;
	$self->{str} =~ s/\s+$//;
	return $self;
}

sub isAlpha {
	my $self = shift;

	unless ($self->{str} =~ /^[a-zA-Z]+$/) {
		$self->error($self->{msgs}->{isAlpha} // $self->{msg} // 'Invalid characters');
	}
	return $self;
}

sub isAlphanumeric {
	my $self = shift;

	unless ($self->{str} =~ /^[a-zA-Z0-9]+$/) {
		$self->error($self->{msgs}->{isAlphanumeric} // $self->{msg} // 'Invalid characters');
	}
	return $self;
}

sub isNumeric {
	my $self = shift;

	unless ($self->{str} =~ /^[0-9]+$/) {
		$self->error($self->{msgs}->{isNumeric} // $self->{msg} // 'Invalid number');
	}
	return $self;
}

sub notNull {
	my $self = shift;

	if ($self->{str} eq '') {
		$self->error($self->{msgs}->{notNull} // $self->{msg} // 'String is empty');
	}
	return $self;
}

sub isNull {
	my $self = shift;

	unless ($self->{str} eq '') {
		$self->error($self->{msgs}->{isNull} // $self->{msg} // 'String is not empty');
	}
	return $self;
}

sub notEmpty {
	my $self = shift;

	if ($self->{str} =~ /^[\s\t\r\n]*$/) {
		$self->error($self->{msgs}->{notEmpty} // $self->{msg} // 'String is whitespace');
	}
	return $self;
}

sub equals {
	my ($self, $equals) = @_;

	unless ($self->{str} eq $equals) {
		$self->error($self->{msgs}->{equals} // $self->{msg} // 'Not equal');
	}
	return $self;
}

sub containes {
	my ($self, $pattern) = @_;

	unless ($self->{str} =~ /$pattern/) {
		$self->error($self->{msgs}->{containes} // $self->{msg} // 'Invalid characters');
	}
	return $self;
}

sub byteLen {
	my ($self, $min, $max) = @_;

	my $length = length $self->{str};
	if ($length < $min) {
		$self->error($self->{msgs}->{byteLen} // $self->{msg} // 'String is too small');
	}
	if (defined $max && $length > $max) {
		$self->error($self->{msgs}->{byteLen} // $self->{msg} // 'String is too large');
	}
	return $self;
}

sub len {
	my ($self, $min, $max) = @_;

	my $length = length decode_utf8($self->{str});
	if ($length < $min) {
		$self->error($self->{msgs}->{len} // $self->{msg} // 'String is too small');
	}
	if (defined $max && $length > $max) {
		$self->error($self->{msgs}->{len} // $self->{msg} // 'String is too large');
	}
	return $self;
}

sub isDate {
	my $self = shift;

	my $str = $self->_fixDate($self->{str});
	unless ($str =~ /^\d{8}$/) {
		$self->error($self->{msgs}->{isDate} // $self->{msg} // 'Not a date');
	}
	eval {
		unless ($str eq Time::Piece->strptime($str, '%Y%m%d')->strftime('%Y%m%d')) {
			$self->error($self->{msgs}->{isDate} // $self->{msg} // 'Not a date');
		}
	};
	if ($@) {
		$self->error($self->{msgs}->{isDate} // $self->{msg} // 'Not a date');
	}
	return $self;
}

sub isAfter {
	my ($self, $compDate) = @_;

	$self->isDate;
	my $origDate = $self->_fixDate($self->{str});
	$compDate = $self->_fixDate($compDate);

	unless ($origDate >= $compDate) {
		$self->error($self->{msgs}->{isAfter} // $self->{msg} // 'Invalid date');
	}
	return $self;
}

sub isBefore {
	my ($self, $compDate) = @_;

	$self->isDate;
	my $origDate = $self->_fixDate($self->{str});
	$compDate = $self->_fixDate($compDate);

	unless ($origDate <= $compDate) {
		$self->error($self->{msgs}->{isBefore} // $self->{msg} // 'Invalid date');
	}
	return $self;
}

sub _fixDate {
	my ($self, $date) = @_;

	if ($date =~ /^(\d{4})[\/-](\d{1,2})[\/-](\d{1,2})$/) {
		$date = sprintf("%04d%02d%02d", $1, $2, $3);
	}
	return $date;
}

package Validator::Chained::Exception;

sub new {
	my $class = shift;
	return bless {}, $class;
}

sub message {
	my ($self, $msg) = @_;

	return $self->{msg} unless (defined $msg);
	$self->{msg} = $msg;
}

1;
