@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'je reversal documents'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_JE_REV as select distinct from I_JournalEntryItem as item

//  left outer join I_JournalEntry as refhead
//    on (
//           refhead.AccountingDocument = item.InvoiceReference
//           or item.InvoiceItemReference is null
//       )
//   on 
//   refhead.CompanyCode            = item.CompanyCode
//   and refhead.FiscalYear             = item.FiscalYear
//   and refhead.AccountingDocumentType = 'DR'

{
      key item.AccountingDocument      as AccountingDocument,
      key item.CompanyCode             as CompanyCode,
      key item.FiscalYear              as FiscalYear,

          item.InvoiceReference        as InvoiceReference,

//          case
//              when refhead.AccountingDocumentType = 'DR'
//                   and item.InvoiceReference is not null
//              then refhead.DocumentReferenceID
//              else null
//          end                          as DocumentReferenceID,
cast( '' as abap.char(20) ) as DocumentReferenceID,
cast( '00000000' as abap.dats ) as OrginalInvoiceDate
//          refhead.DocumentDate         as OrginalInvoiceDate
}

where item.AccountingDocumentType = 'DG'
  and item.Ledger                 = '0L'
and   item.InvoiceItemReference is null
and item.PostingKey = '11'

union all


select distinct from I_JournalEntryItem as item

  inner join I_JournalEntry as refhead
    on refhead.AccountingDocument      = item.InvoiceReference
   and refhead.CompanyCode             = item.CompanyCode
   and refhead.FiscalYear              = item.FiscalYear
   and refhead.AccountingDocumentType  = 'DR'

{
      key item.AccountingDocument      as AccountingDocument,
      key item.CompanyCode             as CompanyCode,
      key item.FiscalYear              as FiscalYear,

          item.InvoiceReference        as InvoiceReference,

          case
              when refhead.AccountingDocumentType = 'DR'
                   and item.InvoiceReference is not null
              then refhead.DocumentReferenceID
              else null
          end                          as DocumentReferenceID,

          refhead.DocumentDate         as OrginalInvoiceDate
}

where item.AccountingDocumentType = 'DG'
  and item.Ledger                 = '0L'
 and item.PostingKey = '11'

//as select distinct from  I_JournalEntryItem as item
// 
// 
// 
//  left outer join I_JournalEntry as refhead
//    on refhead.AccountingDocument = item.InvoiceReference
//    and refhead.CompanyCode       = item.CompanyCode
//    and refhead.FiscalYear        = item.FiscalYear
//    and refhead.AccountingDocumentType = 'DR'
// 
//{
//    key item.AccountingDocument,
//    item.CompanyCode,
//    item.FiscalYear,
//    item.InvoiceReference,
//    
//    case
//        when refhead.AccountingDocumentType = 'DR'
//             and item.InvoiceReference is not null
//        then refhead.DocumentReferenceID
//        else ''
//    end as DocumentReferenceID,
//    refhead.DocumentDate as orginalinvoicedate 
//    
//    
// 
//}
// 
//where item.AccountingDocumentType = 'DG' and item.Ledger = '0L'
 
 
 
 