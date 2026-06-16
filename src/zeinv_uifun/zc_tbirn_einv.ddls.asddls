@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@EndUserText: {
  label: '###GENERATED Core Data Service Entity'
}
@ObjectModel: {
  sapObjectNodeType.name: 'ZTBIRN_EINV'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBIRN_EINV
  provider contract transactional_query
  as projection on ZR_TBIRN_EINV
  association [1..1] to ZR_TBIRN_EINV as _BaseEntity on $projection.Invno = _BaseEntity.Invno
{
  key Invno,
  Ackno,
  Ackdatetime,
  Irn,
  Signedqrcode,
  Qrcode,
  Remarks,
  @Semantics: {
    user.createdBy: true
  }
  CreatedBy,
  @Semantics: {
    systemDateTime.createdAt: true
  }
  CreatedAt,
  @Semantics: {
    user.lastChangedBy: true
  }
  LastChangedBy,
  @Semantics: {
    systemDateTime.lastChangedAt: true
  }
  LastChangedAt,
  @Semantics: {
    systemDateTime.localInstanceLastChangedAt: true
  }
  LocalLastChangedAt,
  Status,
  Additionalfield1,
  Additionalfield2,
  Additionalfield3,
  Additionalfield4,
  Additionalfield5,
  Additionalfield6,
  Vehiclenumber,
  Vehicledate,
  Vehicletype,
  Ewaybillnumber,
  Ewaybilldate,
  Trasportmode,
  Transportmode,
  Transportcode,
  Transportname,
  Transportid,
  Transportdocketnumber,
  Transportdocketdate,
  Ewaybillstatus,
  Distance,
  long_text,
  
  _BaseEntity
}
