use strict;
use Test::More tests => 13;

use Validator::Chain;

my $v = Validator::Chain->new;

subtest 'validate isAlpha' => sub {
	subtest 'success' => sub {
		eval { $v->check('abc')->isAlpha; };
		ok ($@ == '');
		eval { $v->check('ABC')->isAlpha; };
		ok ($@ == '');
		eval { $v->check('abcABC')->isAlpha; };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->check('123')->isAlpha; };
		like ($@->message, qr/Invalid/);
		eval { $v->check('abc123')->isAlpha; };
		like ($@->message, qr/Invalid/);
		eval { $v->check('-()%"!?~=|{}')->isAlpha; };
		like ($@->message, qr/Invalid/);
		eval { $v->check('あいう')->isAlpha; };
		like ($@->message, qr/Invalid/);
	};
};

subtest 'validate isAlphanumeric' => sub {
	subtest 'success' => sub {
		eval { $v->check('abc')->isAlphanumeric; };
		ok ($@ == '');
		eval { $v->check('ABC')->isAlphanumeric; };
		ok ($@ == '');
		eval { $v->check('abcABC')->isAlphanumeric; };
		ok ($@ == '');
		eval { $v->check('123')->isAlphanumeric; };
		ok ($@ == '');
		eval { $v->check('abc123')->isAlphanumeric; };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->check('-()%"!?~=|{}')->isAlphanumeric; };
		like ($@->message, qr/Invalid/);
		eval { $v->check('あいう')->isAlphanumeric; };
		like ($@->message, qr/Invalid/);
	};
};

subtest 'validate isNumeric' => sub {
	subtest 'success' => sub {
		eval { $v->check('123')->isNumeric; };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->check('abc123')->isNumeric; };
		like ($@->message, qr/Invalid/);
		eval { $v->check('-()%"!?~=|{}')->isNumeric; };
		like ($@->message, qr/Invalid/);
		eval { $v->check('あいう')->isNumeric; };
		like ($@->message, qr/Invalid/);
	};
};

subtest 'validate notNull' => sub {
	subtest 'success' => sub {
		eval { $v->check('aaa')->notNull; };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->check()->notNull; };
		like ($@->message, qr/empty/);
		eval { $v->check('')->notNull; };
		like ($@->message, qr/empty/);
	};
};

subtest 'validate isNull' => sub {
	subtest 'success' => sub {
		eval { $v->check()->isNull; };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->check('aaa')->isNull; };
		like ($@->message, qr/not empty/);
	};
};

subtest 'validate notEmpty' => sub {
	subtest 'success' => sub {
		eval { $v->check('aaa')->notEmpty; };
		ok ($@ == '');
		eval { $v->check("aaa\n\r\t\s")->notEmpty; };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->check('    ')->notEmpty; };
		like ($@->message, qr/whitespace/);
		eval { $v->check("\n\t\r  ")->notEmpty; };
		like ($@->message, qr/whitespace/);
	};
};

subtest 'validate equals' => sub {
	$v->check('aaa');
	subtest 'success' => sub {
		eval { $v->equals('aaa'); };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->equals('bbb'); };
		like ($@->message, qr/Not equal/);
	};
};

subtest 'validate containes' => sub {
	$v->check('aaa');
	subtest 'success' => sub {
		eval { $v->containes('a'); };
		ok ($@ == '');
		eval { $v->containes('aa'); };
		ok ($@ == '');
		eval { $v->containes('aaa'); };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->containes('b'); };
		like ($@->message, qr/Invalid/);
		eval { $v->containes('aaaa'); };
		like ($@->message, qr/Invalid/);
	};
};

subtest 'validate len' => sub {
	$v->check('abc');
	subtest 'success' => sub {
		eval { $v->len(3); };
		ok ($@ == '');
		eval { $v->len(3, 4); };
		ok ($@ == '');
		eval { $v->len(3, 3); };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->len(4); };
		like ($@->message, qr/small/);
		eval { $v->len(4, 5); };
		like ($@->message, qr/small/);
		eval { $v->len(1, 2); };
		like ($@->message, qr/large/);
	};
};

subtest 'validate isDate' => sub {
	subtest 'success' => sub {
		eval { $v->check('20140101')->isDate; };
		ok ($@ == '');
		eval { $v->check('2014/01/01')->isDate; };
		ok ($@ == '');
		eval { $v->check('2014-01-01')->isDate; };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->check('20140000')->isDate; };
		like ($@->message, qr/Not a date/);
		eval { $v->check('2014/00/00')->isDate; };
		like ($@->message, qr/Not a date/);
		eval { $v->check('2014-00-00')->isDate; };
		like ($@->message, qr/Not a date/);
		eval { $v->check('20140230')->isDate; };
		like ($@->message, qr/Not a date/);
		eval { $v->check('20149999')->isDate; };
		like ($@->message, qr/Not a date/);
	};
};

subtest 'validate isAfter' => sub {
	subtest 'success' => sub {
		eval { $v->check('20140101')->isAfter('20140101'); };
		ok ($@ == '');
		eval { $v->check('20140101')->isAfter('20131228'); };
		ok ($@ == '');
		eval { $v->check('2014/01/01')->isAfter('2013/12/28'); };
		ok ($@ == '');
		eval { $v->check('2014-01-01')->isAfter('2013-12-28'); };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->check('20140101')->isAfter('20140102'); };
		like ($@->message, qr/Invalid/);
		eval { $v->check('2014/01/01')->isAfter('2014/01/02'); };
		like ($@->message, qr/Invalid/);
		eval { $v->check('2014-01-01')->isAfter('2014-01-02'); };
		like ($@->message, qr/Invalid/);
	};
};

subtest 'validate isBefore' => sub {
	subtest 'success' => sub {
		eval { $v->check('20140101')->isBefore('20140101'); };
		ok ($@ == '');
		eval { $v->check('20140101')->isBefore('20140102'); };
		ok ($@ == '');
		eval { $v->check('2014/01/01')->isBefore('2014/01/02'); };
		ok ($@ == '');
		eval { $v->check('2014-01-01')->isBefore('2014-01-02'); };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->check('20140101')->isBefore('20131228'); };
		like ($@->message, qr/Invalid/);
		eval { $v->check('2014/01/01')->isBefore('2013/12/28'); };
		like ($@->message, qr/Invalid/);
		eval { $v->check('2014-01-01')->isBefore('2013-12-28'); };
		like ($@->message, qr/Invalid/);
	};
};

subtest 'validate isEmail' => sub {
	subtest 'success' => sub {
		eval { $v->check('foo@bar.com')->isEmail };
		ok ($@ == '');
		eval { $v->check('x@x.x')->isEmail };
		ok ($@ == '');
		eval { $v->check('foo@bar.com.au')->isEmail };
		ok ($@ == '');
		eval { $v->check('foo+bar@bar.com')->isEmail };
		ok ($@ == '');
		eval { $v->check('ryomelo300@gmail.com')->isEmail };
		ok ($@ == '');
	};
	subtest 'failure' => sub {
		eval { $v->check('invalidemail@')->isEmail };
		like($@->message, qr/Invalid/);
		eval { $v->check('invalid.com')->isEmail };
		like($@->message, qr/Invalid/);
		eval { $v->check('@invalid.com')->isEmail };
		like($@->message, qr/Invalid/);
	};
};

done_testing;
