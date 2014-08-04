#  EmiteND.pm - 
#
#	Creado: 02/08/2014 
#	UM: 02/08/2014

package EmiteND;

#use Tk::TList;
#use Tk::LabEntry;
#use Tk::LabFrame;
#use Encode 'decode_utf8';
			
sub crea {

	my ($esto, $vp, $bd, $ut, $mt) = @_;
	
	$esto = {};
	$esto->{'baseDatos'} = $bd;
	$esto->{'mensajes'} = $ut;

	$ut->mError("Aún no está programado");
	
	bless $esto;
	return $esto;
}

# Fin del paquete
1;
