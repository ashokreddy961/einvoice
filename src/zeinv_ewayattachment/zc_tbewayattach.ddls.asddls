@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZTBEWAYATTACH'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_TBEWAYATTACH
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TBEWAYATTACH
  association [1..1] to ZR_TBEWAYATTACH as _BaseEntity on $projection.INVNO = _BaseEntity.INVNO and $projection.DOCID = _BaseEntity.DOCID
{
  key Invno,
  key DocID,
  FileName,
  MimeType,
  EwaybillAttachment,
  @Semantics: {
    User.Createdby: true
  }
  Createdby,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  Createdat,
  @Semantics: {
    User.Lastchangedby: true
  }
  Lastchangedby,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  Lastchangedat,
  _BaseEntity
}
