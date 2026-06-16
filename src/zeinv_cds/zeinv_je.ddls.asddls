@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'je documents'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_JE as select from I_JournalEntryItem as JE
 
  left outer join I_OperationalAcctgDocItem as oper
    on  oper.AccountingDocument     = JE.AccountingDocument
    and oper.CompanyCode            = JE.CompanyCode
    and oper.FiscalYear             = JE.FiscalYear
    and oper.AccountingDocumentItem = '001'
 
  left outer join I_PaymentTermsText as pay1
    on oper.PaymentTerms = pay1.PaymentTerms
    
    left outer join I_Customer as cust
on cust.Customer = JE.OffsettingAccount
 or cust.Customer = JE.Customer 
 
    left outer join I_Customer as cust1
on cust1.Customer = oper.Customer
 
 
left outer join I_Address_2 as billaddr
    on cust.AddressID = billaddr.AddressID
    
    left outer join ZEINV_JE_TCS as jetcs
    on jetcs.AccountingDocument = JE.AccountingDocument
    and jetcs.CompanyCode = JE.CompanyCode
    and jetcs.Ledger = JE.Ledger
    and jetcs.FiscalYear = JE.FiscalYear
    
    left outer join I_GLAccountText as gltxt
    on gltxt.GLAccount = JE.GLAccount
    and gltxt.Language = 'E'
    
 
{
key JE.AccountingDocument,
// oper.OriginalReferenceDocument as AccountingDocument,
//substring( oper.OriginalReferenceDocument, 1, 10 ) as AccountingDocument,
    JE.AccountingDocumentItem,
    JE.AccountingDocumentType,
    JE.GLAccount,
    JE.CompanyCodeCurrency,
 
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    JE.DebitAmountInCoCodeCrcy,
 
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    JE.CreditAmountInCoCodeCrcy,
 
    JE.GLAccountType,
    JE.TaxCode,
    oper.BaseUnit,
    JE.OffsettingAccountType,
    JE.OffsettingAccount,
      case 
    when JE.OffsettingAccountType = 'D'
        then JE.OffsettingAccount   
    else JE.Customer      
end as FinalOffsetAccount,
    JE.FiscalYear,
    JE.CompanyCode,
    oper.Customer,
    cust.TaxNumber3 as CustomerGSTIN,
    cust.TaxNumber3 as BillToGSTIN,
    cust.BPCustomerName as     CustomerName,
    billaddr.StreetName      as BillToStreet,
billaddr.HouseNumber     as BillToHouseNo,
billaddr.CityName        as BillToCity,
billaddr.DistrictName    as BillToDistrict,
billaddr.Region          as BillToRegion,
billaddr.PostalCode      as BillToPostalCode,
billaddr.Country         as BillToCountry,
billaddr.StreetPrefixName1 as STREET1,
billaddr.StreetPrefixName2 as STREET2,
billaddr.StreetSuffixName1 as STREET3,
billaddr.StreetSuffixName2 as STREET4,
JE.TransactionCurrency,
   case
    when JE.TransactionCurrency <> 'INR'
        then 'EXP'
        
    when cust.TaxNumber3 is not null
         and cust.TaxNumber3 <> ''
        then 'B2B'
        
    else 'B2C'
end as SupplyType, 
    
//    case
//    when cust.TaxNumber3 is not null
//         and cust.TaxNumber3 <> ''
//    then 'B2B'
//    else 'B2C'
//end as SupplyType,
 
    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    JE.AmountInCompanyCodeCurrency,
    

/* BASE AMOUNT */
 
//    @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
//    case
//        when JE.GLAccountType = 'P'
//            then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
//        else cast( 0 as abap.dec(23,2) )
//    end as BaseLineAmount,

 @Semantics.amount.currencyCode: 'TransactionCurrency'
 JE.AmountInTransactionCurrency,

@Semantics.amount.currencyCode: 'TransactionCurrency'
case
    when JE.TransactionCurrency <> 'INR' and JE.GLAccountType = 'P'
        then abs( cast( JE.AmountInTransactionCurrency as abap.dec(23,2) ) )

    when JE.TransactionCurrency = 'INR' and JE.GLAccountType = 'P'
        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )

    else cast( 0 as abap.dec(23,2) )
end as BaseLineAmount,


@Semantics.amount.currencyCode: 'TransactionCurrency'
case
    when JE.TransactionCurrency <> 'INR'
         and JE.TaxCode = 'FD'
       and  ( JE.GLAccountType = 'P' or JE.GLAccountType = 'N')
        then abs( cast( JE.AmountInTransactionCurrency as abap.dec(23,2) ) )
          //   * 2.5 / 100
           * cast(2.5 as abap.dec(5,2)) / cast(100 as abap.dec(5,2))

    when JE.TransactionCurrency = 'INR'
         and JE.TaxCode = 'FD'
        and  ( JE.GLAccountType = 'P' or JE.GLAccountType = 'N')
        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
 //            * 2.5 / 100
              *  cast(2.5 as abap.dec(5,2)) / cast(100 as abap.dec(5,2))

    when JE.TransactionCurrency <> 'INR'
//         and JE.TaxCode = 'FC'
         and ( JE.TaxCode = 'FC' or JE.TaxCode = 'FI' )

         and  ( JE.GLAccountType = 'P' or JE.GLAccountType = 'N')
        then abs( cast( JE.AmountInTransactionCurrency as abap.dec(23,2) ) )
            // * 9 / 100
            * cast(9 as abap.dec(5,2)) / cast(100 as abap.dec(5,2))

    when JE.TransactionCurrency = 'INR'
//         and JE.TaxCode = 'FC'
         and ( JE.TaxCode = 'FC' or JE.TaxCode = 'FI' )
         and ( JE.GLAccountType = 'P' or JE.GLAccountType = 'N')
        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
             * 9 / 100

    else cast(0 as abap.dec(23,2))
end as CGST_Amount,


@Semantics.amount.currencyCode: 'TransactionCurrency'
case
    when JE.TransactionCurrency <> 'INR'
         and JE.TaxCode = 'FD'
           and  ( JE.GLAccountType = 'P' or JE.GLAccountType = 'N')
        then abs( cast( JE.AmountInTransactionCurrency as abap.dec(23,2) ) )
             //* 2.5 / 100
              *  cast(2.5 as abap.dec(5,2)) / cast(100 as abap.dec(5,2))

    when JE.TransactionCurrency = 'INR'
         and JE.TaxCode = 'FD'
          and  ( JE.GLAccountType = 'P' or JE.GLAccountType = 'N')
        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
             // * 2.5 / 100
           *  cast(2.5 as abap.dec(5,2)) / cast(100 as abap.dec(5,2))

    when JE.TransactionCurrency <> 'INR'
//         and JE.TaxCode = 'FC'
         and ( JE.TaxCode = 'FC' or JE.TaxCode = 'FI' )

     and  ( JE.GLAccountType = 'P' or JE.GLAccountType = 'N')
        then abs( cast( JE.AmountInTransactionCurrency as abap.dec(23,2) ) )
             * 9 / 100

    when JE.TransactionCurrency = 'INR'
//         and JE.TaxCode = 'FC'
         and ( JE.TaxCode = 'FC' or JE.TaxCode = 'FI' )

         and  ( JE.GLAccountType = 'P' or JE.GLAccountType = 'N')
        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
             * 9 / 100

    else cast(0 as abap.dec(23,2))
end as SGST_Amount,


@Semantics.amount.currencyCode: 'TransactionCurrency'
case
    when JE.TransactionCurrency <> 'INR'
//         and JE.TaxCode = 'FB'
and ( JE.TaxCode = 'FB' or JE.TaxCode = 'FH' )
         and (JE.GLAccountType = 'P'  or JE.GLAccountType = 'N')
        then abs( cast( JE.AmountInTransactionCurrency as abap.dec(23,2) ) )
             * 18 / 100

    when JE.TransactionCurrency = 'INR'
//         and JE.TaxCode = 'FB'
and ( JE.TaxCode = 'FB' or JE.TaxCode = 'FH' )
         and ( JE.GLAccountType = 'P' or JE.GLAccountType = 'N')
        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
             * 18 / 100

    else cast(0 as abap.dec(23,2))
end as IGST_Amount,
 
 
/* CGST RATE */
 
cast(
    case
        when JE.TaxCode = 'FD' then 2.5
        when JE.TaxCode = 'FC' then 9
        when JE.TaxCode = 'FI' then 9
        else 0
    end as abap.dec(5,2)
) as CGSTRate,
 
 
/* SGST RATE */
 
    cast(
        case
            when JE.TaxCode = 'FD' then 2.5
            when JE.TaxCode = 'FC' then 9
             when JE.TaxCode = 'FI' then 9
            else 0
        end as abap.dec(5,2)
    ) as SGSTRate,
 
 
/* IGST RATE */
 
    cast(
        case
            when JE.TaxCode = 'FA' then 5
            when JE.TaxCode = 'FB' then 18
                when JE.TaxCode = 'FH' then 18
            else 0
        end as abap.dec(5,2)
    ) as IGSTRate,
 
 
///* CGST AMOUNT */
// 
//@Semantics.amount.currencyCode: 'CompanyCodeCurrency'
//case
//    when JE.TaxCode = 'FD' and JE.GLAccountType = 'P'
//        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
//        * cast( 2.5 as abap.dec(5,2) )
//        / cast( 100 as abap.dec(5,2) )
// 
//    when JE.TaxCode = 'FC' and JE.GLAccountType = 'P'
//        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
//        * cast( 9 as abap.dec(5,2) )
//        / cast( 100 as abap.dec(5,2) )
// 
//    else cast(0 as abap.dec(23,2))
//end as CGST_Amount,
// 
// 
///* SGST AMOUNT */
// 
//@Semantics.amount.currencyCode: 'CompanyCodeCurrency'
//case
//    when JE.TaxCode = 'FD' and JE.GLAccountType = 'P'
//        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
//        * cast( 2.5 as abap.dec(5,2) )
//        / cast( 100 as abap.dec(5,2) )
// 
//    when JE.TaxCode = 'FC' and JE.GLAccountType = 'P'
//        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
//        * cast( 9 as abap.dec(5,2) )
//        / cast( 100 as abap.dec(5,2) )
// 
//    else cast(0 as abap.dec(23,2))
//end as SGST_Amount,
// 
///* IGST AMOUNT */
// 
//  @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
//case
//    when JE.TaxCode = 'FA' and JE.GLAccountType = 'P'
//        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
//        * cast( 5 as abap.dec(5,2) )
//        / cast( 100 as abap.dec(5,2) )
// 
//    when ( JE.TaxCode = 'FB' or JE.TaxCode = 'FH' )  and JE.GLAccountType = 'P'
//        then abs( cast( JE.AmountInCompanyCodeCurrency as abap.dec(23,2) ) )
//        * cast( 18 as abap.dec(5,2) )
//        / cast( 100 as abap.dec(5,2) )
// 
//    else cast(0 as abap.dec(23,2))
//end as IGST_Amount,
 
        pay1.PaymentTermsName as paymentterms,
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
    
    
    jetcs.tcsamt,
    gltxt.GLAccountLongName as GLAccountName,
    oper.Reference1IDByBusinessPartner as CUSTOMERREFERENCE,
    oper.Reference3IDByBusinessPartner as CUSTOMERREFERENCEDATE,
    JE.ReversalReferenceDocument
 
 
}
 
where
(
      ( JE.AccountingDocumentType = 'DR' and (JE.GLAccountType = 'P' or JE.GLAccountType = 'N')  and JE.Ledger = '0L')
   or ( JE.AccountingDocumentType = 'DG' and (JE.GLAccountType = 'P' or JE.GLAccountType = 'N') and JE.Ledger = '0L')
)
 
 
 
 
 
 
 
 