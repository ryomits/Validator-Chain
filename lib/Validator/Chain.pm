package Validator::Chain;
use strict;
use warnings;
use Encode;
use Time::Piece;
use Carp qw/croak/;

sub new {
	my $class = shift;
	return bless {errors => []}, $class;
}

sub check {
	my ($self, $str, $msg) = @_;

	$str = $str // '';
	$self->{str} = Encode::is_utf8($str) ? $str : decode_utf8($str);
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
	my $self = shift;
	my $msg = shift;

	my $e = Validator::Chain::Exception->new;
	$e->message(sprintf($msg, @_));
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

sub isHexadecimal {
	my $self = shift;

	unless ($self->{str} =~ /^[0-9a-fA-F]+$/) {
		$self->error($self->{msgs}->{isHexadecimal} // $self->{msg} // 'Invalid hexadecimal');
	}
	return $self;
}

sub isHexColor {
	my $self = shift;

	unless ($self->{str} =~ /^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/) {
		$self->error($self->{msgs}->{isHexColor} // $self->{msg} // 'Invalid hexcolor');
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
		$self->error($self->{msgs}->{equals} // $self->{msg} // 'Not equal', $equals);
	}
	return $self;
}

sub containes {
	my ($self, $pattern) = @_;

	unless ($self->{str} =~ /$pattern/) {
		$self->error($self->{msgs}->{containes} // $self->{msg} // 'Invalid characters', $pattern);
	}
	return $self;
}

sub len {
	my ($self, $min, $max) = @_;

	my $length = length $self->{str};
	if ($length < $min) {
		$self->error($self->{msgs}->{len} // $self->{msg} // 'String is too small', $min, $max);
	}
	if (defined $max && $length > $max) {
		$self->error($self->{msgs}->{len} // $self->{msg} // 'String is too large', $min, $max);
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
		$self->error($self->{msgs}->{isAfter} // $self->{msg} // 'Invalid date', $compDate);
	}
	return $self;
}

sub isBefore {
	my ($self, $compDate) = @_;

	$self->isDate;
	my $origDate = $self->_fixDate($self->{str});
	$compDate = $self->_fixDate($compDate);

	unless ($origDate <= $compDate) {
		$self->error($self->{msgs}->{isBefore} // $self->{msg} // 'Invalid date', $compDate);
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

sub isEmail {
	my $self = shift;

	unless ($self->{str} =~ /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/) {
		$self->error($self->{msgs}->{isEmail} // $self->{msg} // 'Invalid email');
	}
	return $self;
}

package Validator::Chain::Exception;

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
