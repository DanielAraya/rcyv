#  EmiteND.pm - Prepara Nota de Devolución a partir de una factura
#
#	Creado: 02/08/2014 
#	UM: 06/08/2014

package EmiteND;

use Tk::LabEntry;
use Tk::TList;
use Tk::LabFrame;
use Encode 'decode_utf8';
use Number::Format;

# Datos a registrar
my ($Monto,$FechaC,$Nombre,$Cantidad,$RUT,$Dcmnt,$Prod) ;
my ($Mnsj,$Numero,$Codigo,$UM,$Registro,$Total,$MU);
# Campos
my ($cantidad,$fecha,$monto,$codigo,$um,$nombre,$rut,$dcmnt,$prod,$mu,$total);
# Botones
my ( $bGrb, $bCan, $bReg, $bEle, $bMst) ; 
# Formato de números
my $pesos = new Number::Format(-thousands_sep => '.', -decimal_point => ',');
# Lista de items por devolver
my @datos = () ;

sub crea {

	my ($esto, $vp, $bd, $ut, $mt, $pIva) = @_;
	
	$esto = {};
	$esto->{'baseDatos'} = $bd;
	$esto->{'mensajes'} = $ut;
	$esto->{'ventana'} = $vp;
	$esto->{'marcoT'} = $mt;

	# Inicializa variables
	my %tp = $ut->tipos();
	$Numero = $bd->numeroC('Devuelve') + 1;
	inicializaV();
	$FechaC = $ut->fechaHoy();

	$bd->creaTempD();
	
	# Define ventana
	my $vnt = $vp->Toplevel();
	$esto->{'ventana'} = $vnt;
	my $alt = 420 ;
	$vnt->title("Registra Nota de Devolución");
	$vnt->geometry("440x$alt+490+4");
		
	my $mDatosC = $vnt->Frame(-borderwidth => 1);
	my $mDatosL2 = $vnt->Frame(-borderwidth => 1);
	my $mLista = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => "Productos por devolver");
	my $mItems = $vnt->LabFrame(-borderwidth => 1, -labelside => 'acrosstop',
		-label => "Registra devoluciones");
	my $mBotonesC = $vnt->Frame(-borderwidth => 1);
	my $mBotonesL = $vnt->Frame(-borderwidth => 1);
	my $mMensajes = $vnt->Frame(-borderwidth => 2, -relief=> 'groove' );

	# Barra de mensajes y botón de ayuda
	my $mnsj = $mMensajes->Label(-textvariable => \$Mnsj, -font => $tp{tx},
		-bg => '#F2FFE6', -fg => '#800000',);
	$mnsj->pack(-side => 'right', -expand => 1, -fill => 'x');
	my $img = $vnt->Photo(-file => "info.gif") ;
	my $bAyd = $mMensajes->Button(-image => $img, 
		-command => sub { $ut->ayuda($mt, 'Compras'); } ); 
	$bAyd->pack(-side => 'left', -expand => 0, -fill => 'none');
	$Mnsj = "Para ver Ayuda presione botón 'i'.";
	# Define Lista de datos
	my $listaS = $mLista->Scrolled('TList', -scrollbars => 'oe', -width => 60,
		-selectmode => 'single', -orient => 'horizontal', -font => $tp{mn},
		-command => sub { &modifica($esto) } );
	$esto->{'vLista'} = $listaS;

	# Define botones
	$bReg = $mBotonesL->Button(-text => "Modifica", 
		-command => sub { &registra($esto) } ); 
	$bEle = $mBotonesL->Button(-text => "Mantiene", 
		-command => sub { &elimina($esto) } ); 
	$bGrb = $mBotonesC->Button(-text => "Graba", 
		-command => sub { &graba($esto) } ); 
	$bMst = $mBotonesC->Button(-text => "Items", 
		-command => sub { @datos = muestraLista($esto) } ); 
	$bCan = $mBotonesC->Button(-text => "Cancela", 
		-command => sub { &cancela($esto) } );

	# Campos para datos generales del documento
	$dcmnt = $mDatosC->LabEntry(-label => "Factura # ", -width => 12,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Dcmnt);
	$rut = $mDatosC->LabEntry(-label => "RUT: ", -width => 15,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-justify => 'left', -textvariable => \$RUT);
	$numero = $mDatosC->LabEntry(-label => " Nº: ", -width => 4,
		-labelPack => [-side => "left", -anchor => "w"], #-bg => '#FFFFCC',
		-justify => 'right', -textvariable => \$Numero, -state => 'disabled',
		-disabledbackground => '#FFFFFC', -disabledforeground => '#000000');

	$nombre = $mDatosL2->Label(-textvariable => \$Nombre, -font => $tp{tx});
	$total = $mDatosL2->LabEntry(-label => " Neto ", -width => 10,
		-labelPack => [-side => "left", -anchor => "w"], 
		-justify => 'right', -textvariable => \$Total, -state => 'disabled',
		-disabledbackground => '#FFFFFC', -disabledforeground => '#000000');
	
	# Campos para registro de productos
	$codigo = $mItems->LabEntry(-label => "Código: ", -width => 5,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Codigo, -state => 'disabled',
		-disabledbackground => '#FFFFFC', -disabledforeground => '#000000' );
	$prod = $mItems->Label(-textvariable => \$Prod, -font => $tp{fx});
	$cantidad= $mItems->LabEntry(-label => " Cantidad: ", -width => 6,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Cantidad);
	$um = $mItems->Label(-textvariable => \$UM, -font => $tp{fx});
	$mu = $mItems->LabEntry(-label => " V.Unitario: ", -width => 10,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$MU, -state => 'disabled',
		-disabledbackground => '#FFFFFC', -disabledforeground => '#000000'); 
	$monto = $mItems->LabEntry(-label => " Monto: ", -width => 10,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Monto, -state => 'disabled',
		-disabledbackground => '#FFFFFC', -disabledforeground => '#000000'); 
	
	# Habilita validación de datos
	$rut->bind("<FocusOut>", sub { &buscaF($esto) } );
	$cantidad->bind("<FocusOut>", sub { $Monto = $Cantidad * $MU ; 
		$bReg->focus;} );
	
	# Dibuja interfaz	
	$dcmnt->pack(-side => 'left', -expand => 0, -fill => 'none');
	$rut->pack(-side => 'left', -expand => 0, -fill => 'none');
	$numero->pack(-side => 'left', -expand => 0, -fill => 'none');
	$nombre->pack(-side => 'left', -expand => 0, -fill => 'none');
	$total->pack(-side => 'left', -expand => 0, -fill => 'none');

	$codigo->grid(-row => 0, -column => 0, -sticky => 'nw');	
	$prod->grid(-row => 0, -column => 1, -columnspan => 3, -sticky => 'nw');
	$cantidad->grid(-row => 1, -column => 0, -sticky => 'nw');
	$um->grid(-row => 1, -column => 1, -sticky => 'nw');
	$mu->grid(-row => 1, -column => 2, -sticky => 'nw');
	$monto->grid(-row => 1, -column => 3, -sticky => 'nw');	

	$bGrb->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bMst->pack(-side => 'left', -expand => 0, -fill => 'none');	
	$bEle->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bReg->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bCan->pack(-side => 'left', -expand => 0, -fill => 'none');

	$listaS->pack();
	$mDatosC->pack(-expand => 1);
	$mDatosL2->pack(-expand => 1);
	$mBotonesC->pack(-expand => 1);
	$mLista->pack(-expand => 1);
	$mItems->pack(-expand => 1);
	$mBotonesL->pack(-expand => 1);
	$mMensajes->pack(-expand => 1, -fill => 'both');

	# Inicialmente deshabilita algunos botones
	$bGrb->configure(-state => 'disabled');
	$bMst->configure(-state => 'disabled');
	$bReg->configure(-state => 'disabled');
	$bEle->configure(-state => 'disabled');
	
	$dcmnt->focus;

	bless $esto;
	return $esto;
}

sub inicializaV ( )
{
	$Cantidad = $Registro = $Monto = $Total = $MU = 0;
	$Dcmnt = $RUT = $Codigo = '';
	$Nombre = '                    ';
	$UM = '   ';

}

sub buscaF ( $ )
{ 
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	my $ut = $esto->{'mensajes'};

	if ($Dcmnt eq '') {
		$Mnsj = "Registre número de Factura";
		$dcmnt->focus;
		return ;
	}
	# Valida que sea número entero
	if (not $Dcmnt =~ /^(\d+)$/) {
		$Mnsj = "NO es un número válido.";
		$dcmnt->focus;
		return ;
	}
	# Busca RUT
	if (not $RUT) {
		$Mnsj = "Debe registrar un RUT.";
		$rut->focus;
		return ;
	}
	$RUT = uc($RUT);
	if ( not $ut->vRut($RUT) ) {
		$Mnsj = "El RUT no es válido";
		$rut->focus;
		return ;
	} else {
		my $nmb = $bd->buscaT($RUT);
		if (not $nmb) {
			$Mnsj = "Ese RUT no aparece registrado.";
			$rut->focus;
			return ;
		} 
		$Nombre = decode_utf8(" $nmb");
	}
	# Verifica que la factura NO esté registrada
	my @fct = $bd->datosF($RUT, $Dcmnt);
	if (not @fct) {
		$Mnsj = "Esa Factura NO está registrada.";
		$dcmnt->focus;
		return ;
	} else {
		$Mnsj = " " ;
		$Registro = $fct[0];
		$Total = $fct[6];
		# Crea tabla temporal con items
		$bd->itemsDev($Registro);
		$bMst->configure(-state =>'active');
	}
}

sub muestraLista ( $ ) 
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};
	my $listaS = $esto->{'vLista'};
	
	# Obtiene lista con datos de ítemes registrados
	my @data = $bd->datosItems( $Registro );

	# Completa TList con código, nombre producto, monto y cantidad 
	my ($algo, $mov, $cp, $mnt, $cntd, $np, $u);
	$listaS->delete(0,'end');
	foreach $algo ( @data ) {
		$cp = $algo->[1];  # Código producto
		$mnt = $pesos->format_number( $algo->[4] ); 
		$cntd = $algo->[2] ;
		$u = $algo->[3] ;
		$np = substr decode_utf8($algo->[6]),0,28 ;
		$mov = sprintf("%-4s %-28s %8s %3s %10s", 
			$cp, $np, $cntd, $u, $mnt ) ;
		$listaS->insert('end', -itemtype => 'text', -text => "$mov" ) ;
	}
	$bGrb->configure(-state => 'active');
	# Devuelve una lista de listas con datos de los productos
	return @data;
}

sub cancela ( )
{
	my ($esto) = @_;	
	my $vn = $esto->{'ventana'};
	my $bd = $esto->{'baseDatos'};
	
	$bd->borraTemp();
	$vn->destroy();
}

sub modifica ( )
{
	my ($esto) = @_;
	my $listaS = $esto->{'vLista'};
	my $bd = $esto->{'baseDatos'};
		
	$Mnsj = " ";
	if (not @datos) {
		$Mnsj = "NO hay movimientos para modificar";
		return;
	}
	
#	$bNvo->configure(-state => 'disabled');
	$bReg->configure(-state => 'active');
	$bEle->configure(-state => 'active');
	
	# Obtiene item seleccionado
	my @ns = $listaS->info('selection');
	my $Item = @datos[$ns[0]];
	
	# Rellena campos
	$Codigo = $Item->[1];
	$Cantidad = $Item->[2];
	$UM = $Item->[3];
	$Monto = $Item->[4] ;
	$MU = $Item->[5] ;
	$Prod = $Item->[6];	
	# Obtiene Id del registro
	$Id = $Item->[7];
}

sub elimina ( )
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'} ;
	# Graba
	$bd->borraItemT( $Id );
	
	# Muestra lista actualizada de items
	@datos = muestraLista($esto);

	limpiaCampos();
}

sub graba ( )
{
	my ($esto) = @_;
	my $ut = $esto->{'mensajes'};
	my $bd = $esto->{'baseDatos'};
	my $listaS = $esto->{'vLista'};
	
	$Mnsj = " ";
	# Graba documento
	my $fc = $ut->analizaFecha($FechaC); 
	# Totaliza
	
	$bd->agregaND($Numero,$RUT,$fc,$Dcmnt,$Total);

	limpiaCampos();
	$bGrb->configure(-state => 'disabled');
	$bReg->configure(-state => 'disabled');
	$bEle->configure(-state => 'disabled');

	$listaS->delete(0,'end');
	# Inicializa variables
	inicializaV();
	$Numero = $bd->numeroC('Devuelve') + 1;
	$Dcmnt = '' ; 
	$dcmnt->focus;
}

sub registra ( )
{
	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'} ;
	# Graba datos
	$bd->grabaItemD($Codigo,$Cantidad,$UM,$MU,$Prod,$Monto,$Id);

	# Muestra lista actualizada de items
	@datos = muestraLista($esto);
	
	limpiaCampos();
}

sub limpiaCampos ( )
{
	$codigo->delete(0,'end');
	$Codigo = ' ';
	$Monto = $Cantidad = $MU = 0;
	$Prod = '                    ';

}

# Fin del paquete
1;
