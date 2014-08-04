#  LCompras.pm - Procesa, muestra e imprime Libro de Compras
#
#	Creado: 01/08/2014 
#	UM: 03/08/2014

package LCompras;

use Encode 'decode_utf8';
use Number::Format;
#use Data::Dumper ;

# Formato de números
my $pesos = new Number::Format(-thousands_sep => '.', -decimal_point => ',');
my ($mes, $nMes, $empresa) ;
my @data = @lMeses = ();

sub crea {

	my ($esto, $vp, $mt, $ut, $bd, $emp) = @_;

	$esto = {};
	$esto->{'baseDatos'} = $bd;
	$esto->{'mensajes'} = $ut;

  	# Inicializa variables
	my %tp = $ut->tipos();
	$empresa = $emp ;

	# Define ventanas
	my $vnt = $vp->Toplevel();
	$vnt->title("Procesa Libro de Compras");
	$vnt->geometry("800x480+10+100"); 
	$esto->{'ventana'} = $vnt;

	# Define marco para mostrar resultado
	my $mtA = $vnt->Scrolled('Text', -scrollbars=> 'se', -bg=> 'white',
		-height=> 450 );
	$mtA->tagConfigure('negrita', -font => $tp{ng} ) ;
	$mtA->tagConfigure('detalle', -font => $tp{mn} ) ;

	my $mBotonesC = $vnt->Frame(-borderwidth => 1);
	my $mMensajes = $vnt->Frame(-borderwidth => 2, -relief=> 'groove' );
	# Define campo para seleccionar mes
	my $tMes = $mBotonesC->Label(-text => "Seleccione mes ") ;
	my $meses = $mBotonesC->BrowseEntry(-variable => \$nMes, -state => 'readonly',
		-disabledbackground => '#FFFFFC', -autolimitheight => 1,
		-disabledforeground => '#000000', -autolistwidth => 1,
		-browse2cmd => \&selecciona );
	# Crea listado de meses
	@lMeses = $ut->meses();
	my $algo;
	foreach $algo ( @lMeses ) {
		$meses->insert('end', $algo->[1] ) ;
	}
	# Define botones
	$bMst = $mBotonesC->Button(-text => "Muestra", 
		-command => sub { &valida($esto, $mtA) } );
	$bImp = $mBotonesC->Menubutton(-text => "Archivo", -tearoff => 0, 
	-underline => 0, -indicatoron => 1, -relief => 'raised',-menuitems => 
	[ ['command' => "texto", -command => sub { txt($mtA);} ],
 	  ['command' => "planilla", -command => sub { csv($bd);} ] ] );
	my $bCan = $mBotonesC->Button(-text => "Cancela", 
		-command => sub { $vnt->destroy();} );

	# Barra de mensajes y botón de ayuda
	my $mnsj = $mMensajes->Label(-textvariable => \$Mnsj, -font => $tp{tx} ,
		-bg => '#F2FFE6', -fg => '#800000',);
	$mnsj->pack(-side => 'right', -expand => 1, -fill => 'x');
	my $img = $vnt->Photo(-file => "info.gif") ;
	my $bAyd = $mMensajes->Button(-image => $img, 
		-command => sub { $ut->ayuda($mt, 'LCompras'); } ); 
	$bAyd->pack(-side => 'left', -expand => 0, -fill => 'none');
	$Mnsj = "Para ver Ayuda presione botón 'i'.";

	# Dibuja interfaz
	$tMes->pack(-side => "left", -anchor => "w");
	$meses->pack(-side => "left", -anchor => "w");
	$bMst->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bCan->pack(-side => 'right', -expand => 0, -fill => 'none');
	$bImp->pack(-side => 'right', -expand => 0, -fill => 'none');
	$mMensajes->pack(-expand => 0, -fill => 'both');
	$mBotonesC->pack();
	$mtA->pack(-fill => 'both');
	
#	muestra($bd,$mtA,'Junio',$empresa);
	bless $esto;
	return $esto;
}

# Funciones internas
sub txt ( $ )
{
	my ($marco) = @_;	
	
	my $algo = $marco->get('0.0','end');
	# Genera archivo de texto
	my $d = "data/txt/lcompras.txt" ;
	open ARCHIVO, "> $d" or die $! ;
	print ARCHIVO $algo ;
	close ARCHIVO ;
	$Mnsj = "Grabado en '$d'";
}

sub csv ( $ )
{
	my ($bd) = @_;	

	$d = "data/csv/lcompras.csv" ;
	open ARCHIVO, "> $d" or die $! ;

#	print ARCHIVO "$empr\n";
#	$l = "Balance Tributario  $ejerc";
	print ARCHIVO "$l\n";
	$l = " ";
	print ARCHIVO "$l\n";

	print ARCHIVO "$l\n";
	close ARCHIVO ;
	
	$Mnsj = "Ver archivo '$d'";
}

sub muestra ($ $ $ $)
{
	my ($bd, $mt, $nm, $emp) = @_;
		# Busca datos
	@data = $bd->datosLC($nm);
	if (not @data) {
		$mt->delete('0.0','end');
		$mt->insert('end', "No existen datos\n", 'negrita');
		return ;
	}
	my ($total,$tIva, $tNeto) = (0, 0, 0);
	$mt->delete('0.0','end');
	$mt->insert('end', "$emp\n", 'negrita');
	$mt->insert('end', "Libro de Compras $nMes\n\n", 'negrita');
	my $lin1 = sprintf("%-10s %-25s", 'Fecha', 'Proveedor') ;
	$lin1 .= "    RUT           Número       Neto        IVA",
	$lin1 .= "      Total  Tipo";
	my $lin2 = "-"x100;
	$mt->insert('end',"$lin1\n",'detalle');
	$mt->insert('end',"$lin2\n",'detalle');
# 0 - Numero | 1 - RutP | 2 - Fecha | 3 - Tipo | 4 - Dcmnto | 5 - Total
# 6 - Neto | 7 - IVA | 8 - RegistraLC | 9 - Glosa | 10 - Nombre
	foreach $algo ( @data ) {
		$mov = sprintf("%-10s %-25s %12s %10s %10s %10s %10s %4s", 
			$algo->[2], corta($algo->[10]), $algo->[1], $algo->[4],
			$pesos->format_number($algo->[6]), 
			$pesos->format_number($algo->[7]),
			$pesos->format_number($algo->[5]), $algo->[3] ) ;
		$mt->insert('end', "$mov\n", 'detalle' ) ;
		$total += $algo->[5] ;
		$tIva += $algo->[7] ;
		$tNeto += $algo->[6] ;
	}
	$mt->insert('end',"$lin2\n",'detalle');
	my $ftN = $pesos->format_number($tNeto) ;
	my $ftI = $pesos->format_number($tIva) ;
	my $ftT = $pesos->format_number($total) ;
	$mov = sprintf("%-10s %-25s %12s %10s %10s %10s %10s %4s", 
		'','','','',$ftN,$ftI,$ftT,'');
	$mt->insert('end',"$mov\n",'detalle');
	$lin2 = "="x100;
	$mt->insert('end',"$lin2\n",'detalle');
}

sub abrev ( $ )
{
	my ($algo) = @_;
	my $ct = decode_utf8($algo) ;
	if (length $ct > 24) {
		my @pl = split / /, $ct;
		my $lt = substr $pl[0],0,1;
		$ct =~ s/^$pl[0]/$lt/;
	}
	return $ct ;
}

sub corta ( $ )
{
	my ($algo) = @_;
	my $ct = decode_utf8($algo) ;
	if (length $ct > 24) {
		$ct = substr $ct,0,24;
	}
	return $ct ;
}

sub selecciona {
	my ($jc, $Index) = @_;
	$mes = $lMeses[$Index]->[0];
}

sub valida ( $ ) 
{
	my ($esto,$mt) = @_;
	my $bd = $esto->{'baseDatos'};

	$Mnsj = " ";
	if (not $mes) {
		$Mnsj = "Debe seleccionar un mes."; 
		return;
	}
	muestra($bd,$mt,$mes,$empresa);
}

# Fin del paquete
1;
