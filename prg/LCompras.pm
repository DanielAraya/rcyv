#  LCompras.pm - Procesa, muestra e imprime Libro de Compras
#
#	Creado: 01/08/2014 
#	UM: 06/08/2014

package LCompras;

use Encode ('decode_utf8','encode_utf8' );
use Number::Format;
use OpenOffice::OODoc	2.101;

# Formato de números
my $pesos = new Number::Format(-thousands_sep => '.', -decimal_point => ',');
my ($mes, $nMes, $empresa, $prd, $mostrado ) ;
my @data = ();
my @lMeses = ();

sub crea {

	my ($esto, $vp, $mt, $ut, $bd, $emp, $p) = @_;

	$esto = {};
	$esto->{'baseDatos'} = $bd;
	$esto->{'mensajes'} = $ut;

  	# Inicializa variables
	my %tp = $ut->tipos();
	$empresa = $emp ;
	$prd = $p ;
	
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
	[ ['command' => "txt", -command => sub { txt($mtA);} ],
 	  ['command' => "csv", -command => sub { csv($bd);} ],
 	  ['command' => "ods", -command => sub { ods($bd);} ] 
 	 ] );
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
	
	$mostrado = 0;
	
	bless $esto;
	return $esto;
}

# Funciones internas
sub txt ( $ )
{
	my ($marco) = @_;	
	
	if (not $mostrado) {
		$Mnsj = "DEBE seleccionar un mes y mostrar en pantalla." ;
		return ;
	}
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

	if (not $mostrado) {
		$Mnsj = "Seleccionar un mes y mostrar." ;
		return ;
	}

	$d = "data/csv/lcompras.csv" ;
	open ARCHIVO, "> $d" or die $! ;

	print ARCHIVO "$empresa\n";
	$l = "Libro de Compras $nMes $prd";
	print ARCHIVO "$l\n";
	$l = " ";
	print ARCHIVO "$l\n";
	my ($total,$tIva, $tNeto) = (0, 0, 0);
	foreach $algo ( @data ) {
		$prov = corta($algo->[10]) ;
		$l = "$algo->[2],$prov,$algo->[1],$algo->[4],$algo->[6],$algo->[7],$algo->[5],$algo->[3]" ;
		print ARCHIVO "$l\n";
		$total += $algo->[5] ;
		$tIva += $algo->[7] ;
		$tNeto += $algo->[6] ;
	}
	$l = ", , , ,$tNeto,$tIva,$total";
	print ARCHIVO "$l\n";
	close ARCHIVO ;
	
	$Mnsj = "Ver archivo '$d'";
}

sub ods ( $ )
{
	my ($bd) = @_;	

	if (not $mostrado) {
		$Mnsj = "Seleccionar un mes y mostrar." ;
		return ;
	}

	$d = "data/ods/lcompras.ods" ;
	my $e = encode_utf8($empresa);
	my $generator = 'OpenOffice::OODoc ' . $OpenOffice::OODoc::VERSION;
	my $title = "Libro de Compras $e";
	my $description	= "Archivo creado con $generator";
	my $date = odfLocaltime ;
	my $creator = 'Programa rcyv';
	my $subject = '' ;

	my $archivo	= odfContainer($d, create => 'spreadsheet', 
		opendocument => 'on' ) or die "Falló creación de archivo\n";

	my $meta = odfMeta(container => $archivo, readable_XML => 'on');
	$meta->creation_date($date);
	$meta->date($date);
	$meta->generator($generator);
	$meta->initial_creator($creator);
	$meta->creator($creator);
	$meta->title($title);
	$meta->subject($subject);
	$meta->description($description);

	my $contenido = odfDocument(container => $archivo, readable_XML => 'on');
	my $cols = 8 ; 
	my $lns = scalar(@data) + 4;
	my $hojaUno = $contenido->getTable(0);
	my $hoja = $contenido->appendTable("Compras$mes", $lns, $cols);
	$contenido->removeElement($hojaUno) if $hojaUno;

	my $fila = $contenido->getTableRow($hoja, 0);
	$contenido->cellValue($fila, 0, "$e");
	$l = "Libro de Compras $nMes $prd";
	$fila = $contenido->getTableRow($hoja, 1);
	$contenido->cellValue($fila, 0, $l);
	$fila = $contenido->getTableRow($hoja, 2);
	$contenido->cellValue($fila, 0, 'Fecha');
	$contenido->cellValue($fila, 1, 'Proveedor');
	$contenido->cellValue($fila, 2, 'RUT');
	$l = encode_utf8('Número');
	$contenido->cellValue($fila, 3, $l);
	$contenido->cellValue($fila, 4, 'Neto');
	$contenido->cellValue($fila, 5, 'IVA');
	$contenido->cellValue($fila, 6, 'Total');
	$contenido->cellValue($fila, 7, 'Tipo');	
	my $linea = 3 ;
	foreach $algo ( @data ) {
		$prov = $algo->[10] ;
		$fila = $contenido->getTableRow($hoja, $linea);
		$contenido->cellValue($fila, 0, $algo->[2]);
		$contenido->cellValue($fila, 1, $prov);
		$contenido->cellValue($fila, 2, $algo->[1]);
		$contenido->cellValue($fila, 3, $algo->[4]);
		$contenido->cellValueType($hoja, $linea, 4, 'currency');
		$contenido->cellValue($fila, 4, $algo->[6]);
		$contenido->cellValueType($hoja, $linea, 5, 'currency');
		$contenido->cellValue($fila, 5, $algo->[7]);
		$contenido->cellValueType($hoja, $linea, 6, 'currency');
		$contenido->cellValue($fila, 6, $algo->[5]);
		$contenido->cellValue($fila, 7, $algo->[3]);
		$linea += 1 ;
	}
	$fila = $contenido->getTableRow($hoja, $linea);
	$contenido->cellValueType($hoja, $linea, 4, 'currency');
	$l = "of:=SUM([.E4:.E" . "$linea])";
	$contenido->cellFormula($hoja, $linea, 4, $l);
	$contenido->cellValueType($hoja, $linea, 5, 'currency');
	$l = "of:=SUM([.F4:.F" . "$linea])";
	$contenido->cellFormula($hoja, $linea, 5, $l);
	$contenido->cellValueType($hoja, $linea, 6, 'currency');
	$l = "of:=SUM([.G4:.G" . "$linea])";
	$contenido->cellFormula($hoja, $linea, 6, $l);
	
	$archivo->save;
	
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
	$mt->insert('end', "Libro de Compras $nMes $prd\n\n", 'negrita');
	my $lin1 = sprintf("%-10s %-25s", 'Fecha', 'Proveedor') ;
	$lin1 .= "    RUT           Número       Neto        IVA",
	$lin1 .= "      Total  Tipo";
	my $lin2 = "-"x100;
	$mt->insert('end',"$lin1\n",'detalle');
	$mt->insert('end',"$lin2\n",'detalle');
	my ($numD, $ivaFE) = (0, 0);
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
		$numD += 1;
		$ivaFE += $algo->[7] if $algo->[3] eq 'E' ;
	}
	$mt->insert('end',"$lin2\n",'detalle');
	my $ftN = $pesos->format_number($tNeto) ;
	my $ftI = $pesos->format_number($tIva) ;
	my $ftT = $pesos->format_number($total) ;
	$mov = sprintf("%-10s %-25s %12s %10s %10s %10s %10s %4s", 
		'','','','',$ftN,$ftI,$ftT,'');
	$mt->insert('end',"$mov\n",'detalle');
	$lin2 = "="x100;
	$ftI = $pesos->format_number($ivaFE) ;
	$mt->insert('end',"$lin2\n",'detalle');
	$mt->insert('end', "Total doc.: $numD  -  IVA FE: $ftI \n", 'detalle' ) ;
	
	$mostrado = 1;
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
