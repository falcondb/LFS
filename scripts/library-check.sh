#!/bin/bash
## In my system, these libs are shared libs.
#for lib in lib{gmp,mpfr,mpc}.la; do
for lib in lib{gmp,mpfr,mpc}; do	
echo $lib: $(if find /usr/lib* -name $lib*|
grep -q $lib;then :;else echo not;fi) found
done
unset lib

