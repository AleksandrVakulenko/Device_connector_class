Connector(handle) is an abstract class  for wraping RS232,
USB(virtual COM port) and GPIB connection to an arbitraty I/O device.

Real connection is maintaned by inherited subclasse, scesialized for
some kind of interface type.

Abstract functions must be overrided by the subclass:

1) send function (public):
- high-level wrapper of an abstract send_data

2) read function (public):
- high-level wrapper of an abstract read_data

3) query function (public):
- sends ASCII text to the device and return a response;

------------

Connector_GPIB is a subclass of Connector, specified for maintain
connection by GPIB line using Low-level instace of Matlab built-in
visa object.

------------

Connector_COM_RS232 is a subclass of Connector, specified for maintain
connection by RS232 line using Low-level instace of Matlab built-in
serialport object.

------------

Connector_COM_USB is a subclass of Connector_COM_RS232, specified for maintain
connection by USB in virtual COM port mode. For this case there no need to
specify any of COM port properties.

------------

Connector_empty is a subclass of Connector and could be
used as placeholder of initial(default value) of any variable
of Connector type.

Any attempt of executing public methods of Connector_empty
lead to an error.



