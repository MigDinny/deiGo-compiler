dgos=`ls ./lextests2/*.dgo`
for ef in $dgos
do
   echo "$ef"
   A=${ef//\.dgo/.out_temp}
   B=${ef//\.dgo/.out}
   ./gocompiler -t < $ef > $A
   colordiff --strip-trailing-cr $A $B
   if test ! -z $1 && test $1 = "-c"; then
      rm -Rf $A
   fi
done