Class mom
mom instproc greet {} {
	$self instvar age_
	puts "$age_ year old mom say: How are you doigin?"
}

Class kid -superclass mom
kid instproc greet {} {
	$self instvar age_
	puts "$age_ year old kid say: What's up, dude?"
}

set a [new mom]
$a set age_ 45

set b [new kid]
$b set age_ 15

$a greet
$b greet