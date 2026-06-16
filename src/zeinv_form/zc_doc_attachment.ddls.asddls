@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection view for child attachment table'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_DOC_ATTACHMENT as select from ZI_DOC_ATTACHMENT
{
  key DocId,
  Invno,
  DocType,

  @UI.lineItem: [{ position: 10, label: 'File Name' }]
  @UI.identification: [{ position: 10 }]
  FileName,

  @UI.lineItem: [{ position: 20, label: 'Mime Type' }]
  @UI.identification: [{ position: 20 }]
  MimeType,

  @UI.lineItem: [{ position: 30, label: 'File' }]
  @Semantics.largeObject: {
      mimeType: 'MimeType',
      fileName: 'FileName',
      contentDispositionPreference: #INLINE
  }
  FileData,

  CreatedBy,
  CreatedAt
}
