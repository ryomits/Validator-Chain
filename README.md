Description
===
Validator such as Node-Validator.

Example
===
```
use Validator::Chain;

my $v = Validator::Chain->new;
eval {
	$v->check('  aaa  ')->trim->isAlpha->len(5, 6);
};
if (my $e = $@) {
	print $e->message; # String is too small
}
```

List of validation methods
===
* isAlpha
* isAlphanumeric
* isNumeric
* isHexadecimal
* isHexColor
* notNull
* isNull
* notEmpty
* equals
* containes
* len
* isDate
* isAfter
* isBefore
* isEmail
