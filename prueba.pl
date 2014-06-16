use prg::BaseDatos;
use strict;
use Encode 'decode_utf8';

my $bd = BaseDatos->crea('data/2014.db3');

my @listaU = $bd->datosGU('Grupos');
my $algo ;
foreach $algo ( @listaU ) {
	print decode_utf8($algo->[1])  ;
}
