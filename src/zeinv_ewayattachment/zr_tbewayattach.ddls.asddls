@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZTBEWAYATTACH'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBEWAYATTACH
  as select from ZTB_EWAYATTACH
{
  key invno as Invno,
  key doc_id as DocID,
  file_name as FileName,
  mime_type as MimeType,
  ewaybill_attachment as EwaybillAttachment,
  @Semantics.user.createdBy: true
  createdby as Createdby,
  @Semantics.systemDateTime.createdAt: true
  createdat as Createdat,
  @Semantics.user.lastChangedBy: true
  lastchangedby as Lastchangedby,
  @Semantics.systemDateTime.lastChangedAt: true
  lastchangedat as Lastchangedat
}
