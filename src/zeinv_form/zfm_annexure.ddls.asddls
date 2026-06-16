@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'for  jsto form annexure table details'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZFM_ANNEXURE as select from ztb_annexure
{
  key billingdoc,
  key sno,

      annexmaterialdocumentitem,
      annexmaterial,
      annex_desc,
      annex_qty,
      annex_uom,
      annex_hsn,
      annex_batch
}
