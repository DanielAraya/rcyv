#  Menu.pm - 
#
#	Creado: 15/06/2014 
#	UM: 15/06/2014

package Menu;

#use Tk::TList;
#use Tk::LabEntry;
#use Tk::LabFrame;
#use Encode 'decode_utf8';
			
sub crea {

	my ($esto, $vp, $bd, $ut, $mt) = @_;
	
	$esto = {};
	$esto->{'baseDatos'} = $bd;
	$esto->{'mensajes'} = $ut;

	$ut->mError("En programaci�n");
	
	bless $esto;
	return $esto;
}

# Fin del paquete
1;
