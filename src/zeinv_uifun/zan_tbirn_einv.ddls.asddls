@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'E-Invoice IRN Analytical Cube'
@Metadata.ignorePropagatedAnnotations: true
@Analytics.dataCategory: #CUBE
@ObjectModel: {
modelingPattern: #ANALYTICAL_DIMENSION,
    supportedCapabilities: [#ANALYTICAL_DIMENSION, #CDS_MODELING_ASSOCIATION_TARGET, #SQL_DATA_SOURCE, #CDS_MODELING_DATA_SOURCE]
    }
 

define view entity ZAN_TBIRN_EINV as select from ztb_irn_einv as t0
{
    

key t0.invno as Invno,
   t0.ackno as Ackno,
t0.ackdatetime as Ackdatetime,
t0.irn as Irn,
t0.remarks as Remarks,
t0.created_by as CreatedBy,
t0.created_at as CreatedAt,
t0.last_changed_by as LastChangedBy,
t0.last_changed_at as LastChangedAt,
t0.local_last_changed_at as LocalLastChangedAt,
t0.status as Status,
t0.additionalfield1 as Additionalfield1,
t0.additionalfield2 as Additionalfield2,
t0.additionalfield3 as Additionalfield3,
t0.additionalfield4 as Additionalfield4,
t0.additionalfield5 as Additionalfield5,
t0.additionalfield6 as Additionalfield6,
t0.vehiclenumber as Vehiclenumber,
t0.vehicledate as Vehicledate,
t0.vehicletype as Vehicletype,
t0.ewaybillnumber as Ewaybillnumber,
t0.ewaybilldate as Ewaybilldate,
t0.trasportmode as Trasportmode,
t0.transportmode as Transportmode,
t0.transportcode as Transportcode,
t0.transportname as Transportname,
t0.transportid as Transportid,
t0.transportdocketnumber as Transportdocketnumber,
t0.transportdocketdate as Transportdocketdate,
t0.ewaybillstatus as Ewaybillstatus,
t0.distance as Distance


}

