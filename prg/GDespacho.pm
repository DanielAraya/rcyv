#  GDespacho.pm - 
#
#	Creado: 01/08/2014 
#	UM: 01/08/2014

package GDespacho;

#use Tk::TList;
#use Tk::LabEntry;
#use Tk::LabFrame;
#use Encode 'decode_utf8';
			
sub crea {

	my ($esto, $vp, $bd, $ut, $mt) = @_;
	
	$esto = {};
	$esto->{'baseDatos'} = $bd;
	$esto->{'mensajes'} = $ut;

	$ut->mError("No está desarrollado");
	
	bless $esto;
	return $esto;
}

# Fin del paquete
1;
