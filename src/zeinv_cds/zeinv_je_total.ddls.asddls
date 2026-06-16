@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'je total amount'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_JE_TOTAL as select from ZEINV_JE as jetot
{
 
    key jetot.AccountingDocument,
    jetot.CompanyCodeCurrency,
 
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    sum( cast( jetot.BaseLineAmount as abap.dec(23,2) ) ) as TotalBeforeGST,
 
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    sum( cast( jetot.CGST_Amount as abap.dec(23,2) ) ) as CGST,
 
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    sum( cast( jetot.SGST_Amount as abap.dec(23,2) ) ) as SGST,
 
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    sum( cast( jetot.IGST_Amount as abap.dec(23,2) ) ) as IGST,
 
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    sum( cast( jetot.tcsamt as abap.dec(23,2) ) ) as TCS,
 
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    sum( cast( jetot.BaseLineAmount as abap.dec(23,2) ) )
  + sum( cast( jetot.CGST_Amount as abap.dec(23,2) ) )
  + sum( cast( jetot.SGST_Amount as abap.dec(23,2) ) )
  + sum( cast( jetot.IGST_Amount as abap.dec(23,2) ) )
  + sum( cast( jetot.tcsamt as abap.dec(23,2) ) ) as InvoiceTotal
}
group by jetot.AccountingDocument,
jetot.CompanyCodeCurrency
 
 