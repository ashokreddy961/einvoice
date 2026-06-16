@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'document attachment file view'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_DOC_ATTACHMENT as select from ztb_doc_attach
//association to parent ZEINV_ME_FM as _Header
//  on $projection.Invno = _Header.BillingDocument
{
  key doc_id    as DocId,

  invno         as Invno,
  doc_type      as DocType,

  @UI.lineItem: [{ position: 10, label: 'File Name' }]
  @UI.identification: [{ position: 10 }]
  file_name     as FileName,

  @UI.lineItem: [{ position: 20, label: 'Mime Type' }]
  @UI.identification: [{ position: 20 }]
  mime_type     as MimeType,

  @UI.lineItem: [{ position: 30, label: 'File' }]
  @Semantics.largeObject: {
        mimeType: 'MimeType',
        fileName: 'FileName',
        contentDispositionPreference: #INLINE
  }
  file_data     as FileData,

  created_by    as CreatedBy,
  created_at    as CreatedAt

 // _Header
}




//@AbapCatalog.viewEnhancementCategory: [#NONE]
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'document attachment file view'
//@Metadata.ignorePropagatedAnnotations: true
//define view entity ZI_DOC_ATTACHMENT as select from ztb_doc_attach
//association to parent ZEINV_ME_FM as _Header
//  on $projection.Invno = _Header.BillingDocument
//{
//key  doc_id as DocId,
//    invno as Invno,
//    doc_type as DocType,
//    file_name as FileName,
//    mime_type as MimeType,
//      @Semantics.largeObject: {
//        mimeType: 'MimeType',
//        fileName: 'FileName',
//        contentDispositionPreference: #INLINE
//      }
//    file_data as FileData,
//    created_by as CreatedBy,
//    created_at as CreatedAt,
//    _Header
//}
