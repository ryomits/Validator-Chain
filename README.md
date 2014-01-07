Description
===
Validator such as Node-Validator.

Example
===
```
use Validator::Chained;

my $v = Validator::Chained->new;
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
* byteLen
* len
* isDate
* isAfter
* isBefore
* isEmail
