@EndUserText.label: 'abstract entity for eway details popup'
define abstract entity ZEWAY_POP

{
 
 
@Consumption.valueHelpDefinition: [
  { entity: { name: 'ZVH_TRANS', element: 'TransportMode' } }
]
@EndUserText.label: 'Transporter Mode'
 
  TransportMode : zde_tranmodeui;
@EndUserText.label: 'Transporter Code'
 
  TransportCode : abap.char(15);
@EndUserText.label: 'Transporter Name'
 
  TransportName : abap.char(100);
@EndUserText.label: 'Transporter Id'
 
  TransportId   : abap.char(15);
 
@EndUserText.label: 'Transporter Docket Number'
 
  TransportDocketNumber : abap.char(15);
@EndUserText.label: 'Transporter Docket Date'
 
  TransportDocketDate   : abap.dats;
 
  VehicleNumber         : abap.char(20);
 
@Consumption.valueHelpDefinition: [
  { entity: { name: 'ZVH_VEHICLE', element: 'VehicleType' } }
]  VehicleType           : zde_vehicle_ui;
 
}
 
 