#  Utilização
#  Adicionar gocompiler (compilado) ao PATH
#  (uma boa opção é adicionar a directoria da meta1 ao PATH)
#  Após compilar executar este script
#
#  Funcionalidade
#  Compara todos os casos de teste na pasta meta1
#  Cria o ficheiro *casoteste*.out_temp com resultado de correr cada caso de teste
#
#  Flags
#  -c apagar os ficheiros *casotest*.out_temp após correr cada caso de teste

dgos=`ls ./lextests/*.dgo`
for ef in $dgos
do
   echo "$ef"
   A=${ef//\.dgo/.out_temp}
   B=${ef//\.dgo/.out}
   ./gocompiler -l < $ef > $A
   diff $A $B
   if test ! -z $1 && test $1 = "-c"; then
      rm -Rf $A
   fi
done