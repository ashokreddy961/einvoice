@EndUserText.label: 'custom entity'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_CDS_DB_EINV'

define custom entity ZCE_FORM_EINV
{

  key billing_document : vbeln_va;
  //key fiscalyear : abap.numc(4);
 // key   invoice_date     : abap.char(10);

  @Semantics.largeObject: {
      mimeType: 'mimetype',
      fileName: 'filename',
      contentDispositionPreference: #ATTACHMENT
  }
  form       : abap.rawstring;

  filename   : abap.char(50);

  mimetype   : abap.char(50);

}
