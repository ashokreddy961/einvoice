@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'for billing document total amount'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_BILL_TOTALAMT as select from ZEINV_BILL_TAXAMT as amt
{
    key amt.BillingDocument,
    amt.TransactionCurrency,
 
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum( cast( amt.ZPRO_Rate as abap.dec(23,2) ) ) as TotalBeforeGST,
 
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum( cast( amt.JOCG_Amount as abap.dec(23,2) ) ) as CGST,
 
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum( cast( amt.JOSG_Amount as abap.dec(23,2) ) ) as SGST,
 
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum( cast( amt.JOIG_Amount as abap.dec(23,2) ) ) as IGST,
 
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum( cast( amt.ZPRO_Rate as abap.dec(23,2) ) )
  + sum( cast( amt.JOCG_Amount as abap.dec(23,2) ) )
  + sum( cast( amt.JOSG_Amount as abap.dec(23,2) ) )
  + sum( cast( amt.JOIG_Amount as abap.dec(23,2) ) ) as InvoiceTotal
}
group by
    amt.BillingDocument,
    amt.TransactionCurrency
 
 