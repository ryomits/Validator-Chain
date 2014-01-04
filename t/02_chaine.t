use strict;
use Test::More tests => 1;

use Validator::Chained;

my $v = Validator::Chained->new;

subtest 'validate chained' => sub {
	subtest 'success' => sub {
		$v->check('   aaa   ');
		eval { $v->trim->isAlpha->isAlphanumeric; };
		ok ($@ == '');
		$v->check('2014/01/01');
		eval { $v->trim->isDate->isAfter('2013/12/28')->isBefore('2014/01/02'); };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		$v->check('   aaa   ');
		eval { $v->isAlpha; };
		like ($@->message, qr/Invalid/);
		eval { $v->trim->isAlpha->isAlphanumeric->isNumeric; };
		like ($@->message, qr/Invalid/);
		$v->check('2013/01/01');
		eval { $v->trim->isDate->isAfter('2013/12/28')->isBefore('2014/01/02'); };
		like ($@->message, qr/Invalid/);
		$v->check('2014/01/10');
		eval { $v->trim->isDate->isAfter('2013/12/28')->isBefore('2014/01/02'); };
		like ($@->message, qr/Invalid/);
	};
};

done_testing;
