@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBIRN_EINV'
@EndUserText.label: '###GENERATED Core Data Service Entity'

 
define root view entity ZR_TBIRN_EINV
  as select from ztb_irn_einv
{
  key invno as Invno,
  ackno as Ackno,
  ackdatetime as Ackdatetime,
  irn as Irn,
  signedqrcode as Signedqrcode,
  qrcode as Qrcode,
  remarks as Remarks,
  @Semantics.user.createdBy: true
  created_by as CreatedBy,
  @Semantics.systemDateTime.createdAt: true
  created_at as CreatedAt,
  @Semantics.user.lastChangedBy: true
  last_changed_by as LastChangedBy,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  status as Status,
  additionalfield1 as Additionalfield1,
  additionalfield2 as Additionalfield2,
  additionalfield3 as Additionalfield3,
  additionalfield4 as Additionalfield4,
  additionalfield5 as Additionalfield5,
  additionalfield6 as Additionalfield6,
  vehiclenumber as Vehiclenumber,
  vehicledate as Vehicledate,
  vehicletype as Vehicletype,
  ewaybillnumber as Ewaybillnumber,
  ewaybilldate as Ewaybilldate,
  trasportmode as Trasportmode,
  transportmode as Transportmode,
  transportcode as Transportcode,
  transportname as Transportname,
  transportid as Transportid,
  transportdocketnumber as Transportdocketnumber,
  transportdocketdate as Transportdocketdate,
  ewaybillstatus as Ewaybillstatus,
  distance as Distance,
  long_text 
}
