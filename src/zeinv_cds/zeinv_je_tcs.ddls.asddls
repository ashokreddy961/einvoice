@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'je tcs amount'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_JE_TCS as select from I_JournalEntryItem as jei
 
{
    key jei.AccountingDocument,
    jei.CompanyCode,
    jei.FiscalYear,
            @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    
abs( sum( jei.AmountInCompanyCodeCurrency) ) as tcsamt,
  jei.CompanyCodeCurrency,
    
   jei.AccountingDocumentType,
    jei.Ledger
    
}
 
where (
(AccountingDocumentType = 'DG' and Ledger = '0L' and TransactionTypeDetermination = 'JTC')
or (AccountingDocumentType = 'DR' and Ledger = '0L' and TransactionTypeDetermination = 'JTC')
)
group by
 
jei.AccountingDocument,
    jei.CompanyCode,
    jei.FiscalYear,
    jei.AmountInCompanyCodeCurrency,
    jei.AccountingDocumentType,
      jei.CompanyCodeCurrency,
    jei.Ledger
 
 