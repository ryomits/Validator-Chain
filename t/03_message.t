use strict;
use Test::More tests => 3;

use Validator::Chain;

my $v = Validator::Chain->new;

subtest 'validate message per method' => sub {
	eval {
		$v->check('123', {
			isAlpha => 'アルファベットを入力してください',
		})->isAlpha;
	};
	like ($@->message, qr/アルファベットを入力してください/);

	eval {
		$v->check('あいう', {
			isAlphanumeric => '英数字を入力してください',
		})->isAlphanumeric;
	};
	like ($@->message, qr/英数字を入力してください/);

	eval {
		$v->check('abc', {
			isNumeric => '数値を入力してください',
		})->isNumeric;
	};
	like ($@->message, qr/数値を入力してください/);

	eval {
		$v->check('abcg', {
			isHexadecimal => '16進数を入力してください',
		})->isHexadecimal;
	};
	like ($@->message, qr/16進数を入力してください/);

	eval {
		$v->check('abcg', {
			isHexColor => '16進数を入力してください',
		})->isHexColor;
	};
	like ($@->message, qr/16進数を入力してください/);

	eval {
		$v->check(undef, {
			notNull => '必須項目です',
		})->notNull;
	};
	like ($@->message, qr/必須項目です/);

	eval {
		$v->check('abc', {
			isNull => 'undef',
		})->isNull;
	};
	like ($@->message, qr/undef/);

	eval {
		$v->check('   ', {
			notEmpty => '必須項目です',
		})->notEmpty;
	};
	like ($@->message, qr/必須項目です/);

	eval {
		$v->check('aaa', {
			equals => 'aaaを入力してください',
		})->equals('bbb');
	};
	like ($@->message, qr/aaaを入力してください/);

	eval {
		$v->check('aaa', {
			containes => 'aaを入力してください',
		})->containes('bb');
	};
	like ($@->message, qr/aaを入力してください/);

	eval {
		$v->check('aaa', {
			containes => 'aaを入力してください',
		})->containes('bb');
	};
	like ($@->message, qr/aaを入力してください/);

	eval {
		$v->check('aaaaa', {
			len => '二文字以上四文字以内で入力してください',
		})->len(2, 4);
	};
	like ($@->message, qr/二文字以上四文字以内で入力してください/);

	eval {
		$v->check('aaaaa', '二文字以上四文字以内で入力してください')->len(2, 4);
	};
	like ($@->message, qr/二文字以上四文字以内で入力してください/);

	eval {
		$v->check('2014/00/00', {
			isDate => '正しい日付を入力してください',
		})->isDate;
	};
	like ($@->message, qr/正しい日付を入力してください/);

	eval {
		$v->check('201411001', {
			isDate => '正しい日付を入力してください',
		})->isDate;
	};
	like ($@->message, qr/正しい日付を入力してください/);

	eval {
		$v->check('20130230', {
			isDate => '正しい日付を入力してください',
		})->isDate;
	};
	like ($@->message, qr/正しい日付を入力してください/);

	eval {
		$v->check('20140101', {
			isAfter => '正しい日付を入力してください',
		})->isAfter(20140102);
	};
	like ($@->message, qr/正しい日付を入力してください/);

	eval {
		$v->check('20140101', {
			isBefore => '正しい日付を入力してください',
		})->isBefore(20131228);
	};
	like ($@->message, qr/正しい日付を入力してください/);
};

subtest 'validate message a method' => sub {
	eval {
		$v->check('123', 'アルファベットを入力してください')->isAlpha;
	};
	like ($@->message, qr/アルファベットを入力してください/);

	eval {
		$v->check('あいう', '英数字を入力してください')->isAlphanumeric;
	};
	like ($@->message, qr/英数字を入力してください/);

	eval {
		$v->check('abc', '数値を入力してください')->isNumeric;
	};
	like ($@->message, qr/数値を入力してください/);

	eval {
		$v->check('abcg', '16進数を入力してください')->isHexadecimal;
	};
	like ($@->message, qr/16進数を入力してください/);

	eval {
		$v->check('abcg', '16進数を入力してください')->isHexColor;
	};
	like ($@->message, qr/16進数を入力してください/);

	eval {
		$v->check(undef, '必須項目です')->notNull;
	};
	like ($@->message, qr/必須項目です/);

	eval {
		$v->check('abc', 'undef')->isNull;
	};
	like ($@->message, qr/undef/);

	eval {
		$v->check('   ', '必須項目です')->notEmpty;
	};
	like ($@->message, qr/必須項目です/);

	eval {
		$v->check('aaa', 'aaaを入力してください')->equals('bbb');
	};
	like ($@->message, qr/aaaを入力してください/);

	eval {
		$v->check('aaa', 'aaを入力してください')->containes('bb');
	};
	like ($@->message, qr/aaを入力してください/);

	eval {
		$v->check('aaaaa', '二文字以上四文字以内で入力してください')->len(2, 4);
	};
	like ($@->message, qr/二文字以上四文字以内で入力してください/);

	eval {
		$v->check('2014/00/00', '正しい日付を入力してください')->isDate;
	};
	like ($@->message, qr/正しい日付を入力してください/);

	eval {
		$v->check('201411001', '正しい日付を入力してください')->isDate;
	};
	like ($@->message, qr/正しい日付を入力してください/);

	eval {
		$v->check('20130230', '正しい日付を入力してください')->isDate;
	};
	like ($@->message, qr/正しい日付を入力してください/);

	eval {
		$v->check('20140101', '正しい日付を入力してください')->isAfter(20140102);
	};
	like ($@->message, qr/正しい日付を入力してください/);

	eval {
		$v->check('20140101', '正しい日付を入力してください')->isBefore(20131228);
	};
	like ($@->message, qr/正しい日付を入力してください/);

	eval {
		$v->check('invalid', '正しいEmailを入力してください')->isEmail;
	};
	like ($@->message, qr/正しいEmailを入力してください/);
};

subtest 'validate message chained method' => sub {
	eval {
		$v->check('aaa', {
			isAlpha => 'アルファベットを入力してください',
			len => '四文字以上五文字以内で入力してください',
		})->isAlpha->len(4, 5);
	};
	like ($@->message, qr/四文字以上五文字以内で入力してください/);
};

done_testing;
