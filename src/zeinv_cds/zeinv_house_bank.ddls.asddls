@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'for house bank details to the form'
@Metadata.ignorePropagatedAnnotations: true
define view entity  ZEINV_HOUSE_BANK

//as select from I_CustomerCompany as cc
////left outer join i_
//{
//   key  cc.Customer,
//        cc.CompanyCode,
//       
//        cc.HouseBank,
//
//        cc.PaymentTerms
// 
//}



  as select from I_BillingDocument as bd

  inner join I_CustomerCompany as c
    on c.Customer = bd.SoldToParty

//  inner join ZCUSTGRP_BANK as z
//    on z.CustomerAccountGroup = c.CustomerAccountGroup
//   and z.CompanyCode = bd.CompanyCode

  inner join I_HouseBankAccountLinkage as hbal
    on hbal.CompanyCode = c.CompanyCode
   and hbal.HouseBank = c.HouseBank

  inner join I_HouseBankBasic as hbb
    on hbb.CompanyCode = hbal.CompanyCode
   and hbb.HouseBank = hbal.HouseBank
   
   left outer join I_HouseBankAccountText as htxt on htxt.HouseBankAccount = hbal.HouseBankAccount and htxt.Language = 'E'
   
   
{
  key bd.BillingDocument,
      c.HouseBank,
 //     z.HouseBank,
      hbal.BankName,
      htxt.HouseBankAccountDescription as HouseBankAccount,
      hbal.BankInternalID as IFSC,
     hbal.BankAccount
}
 union all 
 
 select from I_AccountingDocumentJournal( P_Language: 'E' ) as jee
 
 left outer join I_CustomerCompany as c
    on c.Customer = jee.Customer
    
//    left outer join I_CustomerCompany as c1
//    on c.HouseBank = jee.HouseBank
    
    left outer join I_HouseBankAccountLinkage as hbal
    on (hbal.CompanyCode = c.CompanyCode   )
   and (hbal.HouseBank = c.HouseBank )
   
   left outer join I_HouseBankAccountLinkage as hba2
    on ( hba2.CompanyCode = jee.CompanyCode  )
   and ( hba2.HouseBank = jee.HouseBank)
   
   left outer join I_HouseBankAccountText as htxt on htxt.HouseBankAccount = hbal.HouseBankAccount and htxt.Language = 'E'
   
   left outer join I_HouseBankAccountText as htxt1 on htxt1.HouseBankAccount = hba2.HouseBankAccount and htxt1.Language = 'E'
   
   {
    key jee.AccountingDocument as BillingDocument,
    case when (jee.HouseBank = '' or jee.HouseBank is null) then c.HouseBank else jee.HouseBank end as HouseBank,
    case when (jee.HouseBank = '' or jee.HouseBank is null) then hbal.BankName else hba2.BankName end as BankName,
    case when (jee.HouseBank = '' or jee.HouseBank is null) then htxt.HouseBankAccountDescription else htxt1.HouseBankAccountDescription end as HouseBankAccount,
    case when (jee.HouseBank = '' or jee.HouseBank is null) then hbal.BankInternalID else hba2.BankInternalID end as IFSC,
    case when (jee.HouseBank = '' or jee.HouseBank is null) then hbal.BankAccount else hba2.BankAccount end as BankAccount
    
     //hbal.BankName,
    //  hbal.HouseBankAccount as HouseBankAccount,
     // hbal.BankInternalID as IFSC,
    // hbal.BankAccount
   
   }
   where (jee.AccountingDocumentType = 'DR' or jee.AccountingDocumentType = 'DG' ) and jee.Customer <> '' and jee.LedgerGLLineItem = '000001' 
   and jee.Ledger = '0L' 
   
 
 

