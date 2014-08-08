#  Gastos.pm - Registra facturas de gastos y compra de activos
#
#	Creado: 15/06/2014 
#	UM: 03/08/2014

package Gastos;

use Tk::LabEntry;
use Encode 'decode_utf8';
use Number::Format;

# Datos a registrar
my ($Glosa,$Fecha,$Neto,$Iva,$Total,$Nombre,$TipoF,$RUT,$Dcmnt) ;
my ($Mnsj,$pIva,$Numero);
# Campos
my ($glosa,$fecha,$neto,$iva,$total,$nombre,$rut,$dcmnt,$fa,$fg);
# Botones
my ($bNvo, $bGrb, $bCan) ; 
	
sub crea {

	my ($esto, $vp, $bd, $ut, $mt, $pIva) = @_;
	
	$esto = {};
	$esto->{'baseDatos'} = $bd;
	$esto->{'mensajes'} = $ut;
	$esto->{'ventana'} = $vp;
	$esto->{'marcoT'} = $mt;

	# Inicializa variables
	my %tp = $ut->tipos();
	$Numero = $bd->numeroC('Compras') + 1;
#	$FechaC = $ut->fechaHoy();
	inicializaV();
	
	# Define ventana
	my $vnt = $vp->Toplevel();
	$esto->{'ventana'} = $vnt;
	my $alt = 200 ;
	$vnt->title("Registra Otras Facturas");
	$vnt->geometry("440x$alt+490+4");
		
	my $mDatosC = $vnt->Frame(-borderwidth => 1);
	my $mDatosL2 = $vnt->Frame(-borderwidth => 1);
	my $mDatosN = $vnt->Frame(-borderwidth => 1);
	my $mDatosL3 = $vnt->Frame(-borderwidth => 1);
	my $mDatosL4 = $vnt->Frame(-borderwidth => 1);
	my $mBotonesC = $vnt->Frame(-borderwidth => 1);
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

	# Define botones
	$bGrb = $mBotonesC->Button(-text => "Graba", 
		-command => sub { &graba($esto) } ); 
	$bNvo = $mBotonesC->Button(-text => "Otra", 
		-command => sub { &otra($esto) } ); 
	$bCan = $mBotonesC->Button(-text => "Cancela", 
		-command => sub { $vnt->destroy() } );

	# Campos para datos generales del documento
	$dcmnt = $mDatosC->LabEntry(-label => "Documento # ", -width => 12,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Dcmnt);
	$fa = $mDatosC->Radiobutton( -text => "Activo", -value => 'A', 
		-variable => \$TipoF );
	$fg = $mDatosC->Radiobutton( -text => "Gasto", -value => 'G', 
		-variable => \$TipoF );

	$rut = $mDatosL2->LabEntry(-label => "RUT: ", -width => 15,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-justify => 'left', -textvariable => \$RUT);
	$fecha = $mDatosL2->LabEntry(-label => " Fecha:", -width => 10,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-textvariable => \$Fecha );
	$numero = $mDatosL2->LabEntry(-label => " Nº: ", -width => 4,
		-labelPack => [-side => "left", -anchor => "w"], #-bg => '#FFFFCC',
		-justify => 'right', -textvariable => \$Numero, -state => 'disabled',
		-disabledbackground => '#FFFFFC', -disabledforeground => '#000000');

	$nombre = $mDatosN->Label(-textvariable => \$Nombre, -font => $tp{tx});

	$neto = $mDatosL3->LabEntry(-label => "Neto: ", -width => 12,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-justify => 'right', -textvariable => \$Neto);
	$iva = $mDatosL3->LabEntry(-label => " IVA: ", -width => 12,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-justify => 'right', -textvariable => \$Iva );
	$total = $mDatosL3->LabEntry(-label => " Total: ", -width => 12,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-justify => 'right', -textvariable => \$Total );
	$glosa = $mDatosL4->LabEntry(-label => " Glosa: ", -width => 35,
		-labelPack => [-side => "left", -anchor => "w"], -bg => '#FFFFCC',
		-justify => 'left', -textvariable => \$Glosa );
	
	# Habilita validación de datos
	$fecha->bind("<FocusIn>", sub { &buscaDoc($esto) } );
	$neto->bind("<FocusOut>", sub { &totaliza() } );
	$iva->bind("<FocusOut>", sub { $Total = $Neto + $Iva ; } );
	$glosa->bind("<FocusIn>", sub { $bGrb->configure(-state => 'active'); } );

	# Dibuja interfaz	
	$dcmnt->pack(-side => 'left', -expand => 0, -fill => 'none');
	$fa->pack(-side => 'left', -expand => 0, -fill => 'none');
	$fg->pack(-side => 'left', -expand => 0, -fill => 'none');

	$rut->pack(-side => 'left', -expand => 0, -fill => 'none');
	$fecha->pack(-side => 'left', -expand => 0, -fill => 'none');
	$numero->pack(-side => 'left', -expand => 0, -fill => 'none');

	$nombre->pack(-side => 'left', -expand => 0, -fill => 'none');

	$neto->pack(-side => 'left', -expand => 0, -fill => 'none');
	$iva->pack(-side => 'left', -expand => 0, -fill => 'none');
	$total->pack(-side => 'left', -expand => 0, -fill => 'none'); 
	$glosa->pack(-side => 'left', -expand => 0, -fill => 'none'); 
	
	$bGrb->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bNvo->pack(-side => 'left', -expand => 0, -fill => 'none');
	$bCan->pack(-side => 'left', -expand => 0, -fill => 'none');

	$mDatosC->pack(-expand => 1);
	$mDatosL2->pack(-expand => 1);
	$mDatosN->pack(-expand => 1);
	$mDatosL3->pack(-expand => 1);
	$mDatosL4->pack(-expand => 1);
	$mBotonesC->pack(-expand => 1);
	$mMensajes->pack(-expand => 1, -fill => 'both');

	# Inicialmente deshabilita algunos botones
	$bGrb->configure(-state => 'disabled');
	$bNvo->configure(-state => 'disabled');
	
	$dcmnt->focus;

	bless $esto;
	return $esto;
}

sub inicializaV ( )
{
	$Total = $Neto = $Iva = 0;
	$Dcmnt = $RUT = $Fecha = $TipoF = '';
	$Nombre = $Glosa = '                    ';

}

sub buscaDoc ( $ )
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
	my $fct = $bd->buscaDC($RUT, $Dcmnt);
	if ($fct) {
		$Mnsj = "Esa Factura ya está registrada.";
		$dcmnt->focus;
		return ;
	}
}

sub graba ( )
{
	my ($esto) = @_;
	my $ut = $esto->{'mensajes'};
	my $bd = $esto->{'baseDatos'};
	
	# Verifica que se completen datos básicos
	if ($TipoF eq '' ) {
		$Mnsj = "Debe marcar tipo de factura.";
		$fa->focus;
		return;				
	}
	if ($Fecha eq '' ) {
		$Mnsj = "Anote la fecha de la factura.";
		$fecha->focus;
		return;
	}
	$Mnsj = " ";

	# Graba documento
	my $fc = $ut->analizaFecha($Fecha); 
	$bd->agregaF($Numero,$RUT,$fc,$TipoF,$Dcmnt,$Total,$Neto,$Iva,$Glosa);

	$bGrb->configure(-state => 'disabled');
	$bNvo->configure(-state => 'active');

}

sub otra ( ) {

	my ($esto) = @_;
	my $bd = $esto->{'baseDatos'};

	$bNvo->configure(-state => 'disabled');
	# Inicializa variables
	inicializaV();
	$Numero = $bd->numeroC('Compras') + 1;
	$dcmnt->focus;
}

sub totaliza ( ) 
{
	$Iva = sprintf("%.0f", $Neto * $pIva );
	$Total = $Neto + $Iva ;
}

# Fin del paquete
1;
