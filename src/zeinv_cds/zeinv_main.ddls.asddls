@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'main cds for einvoice and eway'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_MAIN as select distinct  from I_BillingDocumentItem as b1
left outer join I_BillingDocument as b2 on b1.BillingDocument = b2.BillingDocument 
and b1.CompanyCode = b2.CompanyCode
left outer join I_CompanyCode as comp1 on b1.CompanyCode = comp1.CompanyCode
left outer join I_BusinessPlace as bus1 on b1.CompanyCode = bus1.CompanyCode 
and b1.Plant = bus1.BusinessPlace
left outer join I_Plant as p1 on p1.Plant = b1.Plant
left outer join I_Address_2 as a1 on p1.AddressID = a1.AddressID
left outer join I_Customer as c1 on b1.SoldToParty = c1.Customer
left outer join I_PaymentTermsText as pay1 on b2.CustomerPaymentTerms = pay1.PaymentTerms
left outer join I_ProductPlantIntlTrd as pp1 on b1.Product = pp1.Product 
and b1.Plant = pp1.Plant
left outer join ZEINV_BILL_TAXAMT as z1 on z1.BillingDocument = b1.BillingDocument 
and z1.BillingDocumentItem = b1.BillingDocumentItem
left outer join I_BillingDocumentPartner as bdp on c1.AddressID = bdp.AddressID
 and bdp.BillingDocument = b2.BillingDocument
//left outer join I_BillingDocumentPartner as bdp on b2.BillingDocument = bdp.BillingDocument and c1.Customer = bdp.Customer
//left outer join I_BillingDocItemPartner as bdp2 on b1.BillingDocument = bdp2.BillingDocument 
//and b1.BillingDocumentItem = bdp2.BillingDocumentItem
//left outer join I_Address_2 as bp on c1.AddressID = bp.AddressID and c1.AddressSearchTerm1 = bp.AddressSearchTerm1

left outer join ZEINV_BP_BILLADD as bp3
  on bp3.BillingDocument = b1.BillingDocument
  
  left outer join ZEINV_BILL_REF as f2 on b1.BillingDocument = f2.BillingDocument 
  and b1.BillingDocumentItem = f2.BillingDocumentItem 
  
 left outer join I_Product as prod on prod.Product = b1.Product 
 
 left outer join ZEINV_BILL_TOTALAMT as btot
  on btot.BillingDocument = b1.BillingDocument
  
  left outer join ZEINV_BILLPAY_DAYS as payc
  on payc.PaymentTerms = b2.CustomerPaymentTerms
  
  left outer join I_RegionText as reg
  on reg.Region = b1.Region 
  and reg.Country = b1.Country
  and reg.Language = 'E'
  
 left outer join I_CustomerSalesArea as cs
  on cs.Customer = c1.Customer
left outer join I_CustomerGroupText as cgt
  on cgt.CustomerGroup = cs.CustomerGroup
  and cgt.Language = 'E'
  
  left outer join ZEINV_HOUSE_BANK as bck on bck.BillingDocument = b1.BillingDocument
  left outer join I_SalesDocument  as so  on b1.SalesDocument = so.SalesDocument
  

  {
key b1.BillingDocument,
b1.BillingDocumentItem,
cast( '' as abap.char(40) ) as itemcode,
comp1.CompanyCodeName,
bus1.IN_GSTIdentificationNumber as companygstin,
p1.Plant,
p1.PlantName,
a1.CityName,
a1.DistrictName,
a1.PostalCode,
a1.StreetName,
a1.StreetPrefixName1,
a1.StreetPrefixName2,
a1.StreetSuffixName1,
a1.OrganizationName1,
c1.Customer,
c1.TaxNumber3,
c1.StreetName as customerstreetname,
c1.CityName as customercity,
c1.PostalCode as customerpost,
c1.CustomerName,
cast( '' as abap.char(10)) as CustomerHouse,
cast( '' as abap.char(40)) as CustomerDistrict,
cast( '' as abap.char(3)) as CustomerRegion,
cast( '' as abap.char(3)) as CustomerCountry,

cast( '' as abap.char(40)) as customerSTREET1,
cast( '' as abap.char(40)) as customerSTREET2,
cast( '' as abap.char(40)) as customerSTREET3,
cast( '' as abap.char(40)) as customerSTREET4,
b1.BillingDocumentDate as invoicedate,
pay1.PaymentTermsName,
//dats_add_days(
//    b1.BillingDocumentDate,
//    cast( coalesce(payc.CashDiscount2Days, 0) as abap.int4 ),
//    'FAIL'
//) as PaymentDueDate,
dats_add_days(
    b1.BillingDocumentDate,
    payc.FinalDays,
    'FAIL'
) as PaymentDueDate,

reg.RegionName as placeofsupply,
//reg.RegionName as placeofsupply,

//b1.BillingDocumentItemText,
//b1.YY1_BLITEMLONGTEXT_BDI as BillingDocumentItemText,
case when prod.YY1_ItemLong_Text_PRD    <> ''
then prod.YY1_ItemLong_Text_PRD 
else  b1.BillingDocumentItemText  end as BillingDocumentItemText,
//case when prod.YY1_ItemLong_Text_PRD  is null
//then b1.BillingDocumentItemText 
//else prod.YY1_ItemLong_Text_PRD end as BillingDocumentItemText,
b1.BaseUnit as uom,
//@Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
cast(b1.BillingQuantity as abap.char( 30 )) as BillingQuantity,
//@Semantics.amount.currencyCode: 'TransactionCurrency'
cast(b1.NetAmount as abap.dec( 23, 2 )) as NetAmount,
pp1.ConsumptionTaxCtrlCode as hsncode,
b1.BillingQuantityUnit ,
//z1.ZPRO_Rate as netpriceamount,

case
  when z1.ZPRO_Rate is null 
  then cast( 0 as abap.dec(23,2) )
  else cast( z1.ZPRO_Rate as abap.dec(23,2) )
end as netpriceamount,

@Semantics.amount.currencyCode: 'TransactionCurrency'
//z1.JOCG_Amount as cgstamount,
//cast( z1.JOCG_Amount as abap.dec(23,2) ) as cgstamount,
case
  when z1.JOCG_Amount is null 
  then 0
  else cast( z1.JOCG_Amount as abap.dec(23,2) )
end as cgstamount,

@Semantics.amount.currencyCode: 'TransactionCurrency'
//z1.JOIG_Amount as igstamount,
//cast( z1.JOIG_Amount as abap.dec(23,2) ) as igstamount,
case
  when z1.JOIG_Amount is null 
  then 0
  else cast( z1.JOIG_Amount as abap.dec(23,2) )
end as igstamount,

@Semantics.amount.currencyCode: 'TransactionCurrency'
//z1.JOSG_Amount as sgstamount,
//cast( z1.JOSG_Amount as abap.dec(23,2) ) as sgstamount,
case
  when z1.JOSG_Amount is null 
  then 0
  else cast( z1.JOSG_Amount as abap.dec(23,2) )
end as sgstamount,

z1.Cgst_rate,
z1.igst_rate,
z1.sgst_rate,
//cast( z1.SGSTPER  as abap.dec(23,2) ) as SGSTPER,
//cast( z1.CGSTPER as abap.dec(23,2) ) as CGSTPER,
//
//cast( z1.IGSTPER as abap.dec(23,2) ) as IGSTPER,

//cast( replace( z1.SGSTPER, '%', '' ) as abap.dec(23,2) ) as SGSTPER,
//cast( replace( z1.CGSTPER, '%', '' ) as abap.dec(23,2) ) as CGSTPER,
//cast( replace( z1.IGSTPER, '%', '' ) as abap.dec(23,2) ) as IGSTPER,
case
  when z1.SGSTPER is null
       or z1.SGSTPER = ''
       or z1.SGSTPER = '%'
  then cast( 0 as abap.dec(23,2) )
  else cast( replace( z1.SGSTPER, '%', '' ) as abap.dec(23,2) )
end as SGSTPER,

case
  when z1.CGSTPER is null
       or z1.CGSTPER = ''
       or z1.CGSTPER = '%'
  then cast( 0 as abap.dec(23,2) )
  else cast( replace( z1.CGSTPER, '%', '' ) as abap.dec(23,2) )
end as CGSTPER,

case
  when z1.IGSTPER is null
       or z1.IGSTPER = ''
       or z1.IGSTPER = '%'
  then cast( 0 as abap.dec(23,2) )
  else cast( replace( z1.IGSTPER, '%', '' ) as abap.dec(23,2) )
end as IGSTPER,

case
  when z1.Freight_Amount is null
  then cast( 0 as abap.dec(23,2) )
  else cast( z1.Freight_Amount as abap.dec(23,2) )
end as FreightAmount,

//b1.YY1_Po_date_BDI,
//b1.YY1_PO_Num_BDI,
so.CustomerPurchaseOrderDate as YY1_Po_date_BDI,
so.PurchaseOrderByCustomer as YY1_PO_Num_BDI,
b1.TaxCode as taxcode,

b1.TransactionCurrency,
//BANK.BankAccount,
//BANK.BankAccountHolderName,
//BANK.BankName,
//BANK.SWIFTCode,
//BANK.BankNumber
cast(b2.BillingDocumentType as abap.char( 9 )) as BillingDocumentType,
bp3.BillToCustomer,
//bp3.BillToName,
cast( bp3.BillToName as abap.char(100)) as BillToName,
bp3.BillToStreet,
bp3.BillToHouseNo,
bp3.BillToCity,
bp3.BillToDistrict,
bp3.BillToRegion,
bp3.BillToPostalCode,
bp3.BillToCountry,
bp3.BILLTOSTREET1,
bp3.BILLTOSTREET2,
bp3.BILLTOSTREET3,
bp3.BILLTOSTREET4,
cast( '' as abap.char(20)) as billtogstin,

bp3.ShipToCustomer,
bp3.ShipToName,
//bp3.ShipToGSTIN
cast( '' as abap.char(18) ) as ShipToGSTIN,
cast(bp3.ShipToStreet as abap.char( 200 ) ) as ShipToStreet,


cast( bp3.ShipToHouseNo as abap.char(100) ) as ShipToHouseNo ,
cast( bp3.ShipToCity as abap.char( 100 ) ) as ShipToCity ,
cast(bp3.ShipToDistrict as abap.char(100) ) as ShipToDistrict,
cast(bp3.ShipToRegion as abap.char(10) ) as ShipToRegion,
cast(bp3.ShipToPostalCode as abap.char( 10 ) ) as ShipToPostalCode,
cast( bp3.ShipToCountry as abap.char(50)) as ShipToCountry,
cast( bp3.SHIPTOSTREET1 as abap.char(200) ) as SHIPTOSTREET1,
cast( bp3.SHIPTOSTREET2 as abap.char(200) ) as SHIPTOSTREET2,
cast( bp3.SHIPTOSTREET3 as abap.char(200) ) as SHIPTOSTREET3,
cast( bp3.SHIPTOSTREET4 as abap.char(200) ) as SHIPTOSTREET4 ,

cast( '' as abap.char(30)) as payertoCustomer,
cast( '' as abap.char(40)) as payertoName,
cast( '' as abap.char(60)) as payerToStreet,
cast('' as abap.char(10)) as payerToHouseNo,
cast( '' as abap.char(40)) as payerToCity,
cast( '' as abap.char(40)) as payerToDistrict,
cast( '' as abap.char(13)) as payerToRegion,
cast( '' as abap.char(10)) as payerPostalCode,
cast( '' as abap.char(3)) as payerCountry,

cast( '' as abap.char(40)) as payerSTREET1,
cast( '' as abap.char(40)) as payerSTREET2,
cast( '' as abap.char(40)) as payerSTREET3,
cast( '' as abap.char(40)) as payerSTREET4,
 b2.LastChangeDateTime  as LastChangeDateTime,
//b2.LastChangeDateTime,
b2.DocumentReferenceID,
cast(case 
    when c1.TaxNumber3 is not null and c1.TaxNumber3 <> '' 
    then 'B2B'
    else 'B2C'
end as abap.char( 4 ))
as SupplyType,
//cast ( b1.YY1_Supplytype_BDI_BDI as abap.char( 4 )  )as SupplyType,
f2.F2ReferencedDocument,
cast( f2.OriginalInvoiceDate as abap.dats) as orginalinvoicedate,

cast( 0 as abap.dec(23,2) ) as tcsamount,
b2.CompanyCode,
b2.FiscalYear,
cast( '' as abap.char(255) ) as GLAccountName,
cast( btot.InvoiceTotal as abap.dec(23,2) ) as InvoiceTotal,
cs.CustomerGroup,
cgt.CustomerGroupName as CustomerGroupText,
bck.BankAccount,
bck.BankName,
bck.HouseBank,
bck.HouseBankAccount,
bck.IFSC,
cast ('' as abap.char( 20 )) as REVERSALDOCUMENTID,
cast ('' as abap.char( 10 )) as REVERSALDOCUMENTNO,
cast ( '' as abap.char( 40 )) as YY1_CustomerNamepo_PDH ,
cast ( '' as abap.char( 180 )) as YY1_CustomerAddresspo_PDH,
cast ( '' as abap.char(4)) as SupplyingPlant,
cast ( '' as abap.char( 10 ) ) as invoicereversal,
cast( '' as abap.char(40))  as AnnexureMaterial,
cast( '' as abap.char(10)) as AnnexureMaterialDocumentItem,

cast( '' as abap.char(200)) as AnnexureDesc,
cast( 0  as abap.dec(23,3)) as AnnexureQty,
cast( '' as abap.unit(3))   as AnnexureUOM,
cast( '' as abap.char(20))  as AnnexureHSN,
cast( '' as abap.char(20))  as AnnexureBatch,
cast( '' as abap.char(18)) as JEAssignmentReference,
cast( '' as abap.char(100))  as LUTNo,
cast( '' as abap.char(20) ) as referencecodeyear,
cast( '' as abap.char(20)) as WBS_ELEMENT_ID,
cast( '' as abap.char(30)) as WBS_ELEMENT_NAME,
cast( '' as abap.char(50)) as WBS_ELEMENT_DESC,
cast( '' as abap.char(3)) as taxindicator



}
where (b1.BillingDocumentType = 'F2'  or b1.BillingDocumentType = 'CBRE'  )  


union all

select  distinct from I_JournalEntryItem as item

inner join I_JournalEntry as head
on item.AccountingDocument = head.AccountingDocument
and item.CompanyCode = head.CompanyCode
and item.FiscalYear = head.FiscalYear

left outer join ZEINV_JE as jeamt
on jeamt.AccountingDocument = item.AccountingDocument
and jeamt.AccountingDocumentItem = item.AccountingDocumentItem
and jeamt.CompanyCode = item.CompanyCode
and jeamt.FiscalYear = item.FiscalYear
//and jeamt.GLAccountType = 'P'

left outer join I_BusinessPlace as bus1
  on bus1.CompanyCode = item.CompanyCode
  and bus1.BusinessPlace = item.Plant
 //and bus1.BusinessPlace = head.Branch
  
  
left outer join ZEINV_JE_TOTAL as jtot
  on jtot.AccountingDocument = item.AccountingDocument
  left outer join I_PaymentTermsConditions as payc
on payc.PaymentTerms = jeamt.paymentterms

left outer join ZEINV_BILLPAY_DAYS as payd
  on payd.PaymentTerms = jeamt.paymentterms
  left outer join I_Plant as p1
  on p1.Plant = item.Plant
 //  on p1.Plant = head.Branch
 

left outer join I_Address_2 as a1
  on p1.AddressID = a1.AddressID

left outer join I_RegionText as reg
  on reg.Region = a1.Region
  and reg.Country = a1.Country
 and reg.Language = 'E'


  left outer join I_CustomerSalesArea as cs
  on cs.Customer = jeamt.OffsettingAccount
  
  left outer join I_CustomerGroupText as cgt
  on cgt.CustomerGroup = cs.CustomerGroup
  and cgt.Language = 'E'
  left outer join I_Plant as p 
  on p.AddressID = a1.AddressID
  
  left outer join ZEINV_HOUSE_BANK as bck on bck.BillingDocument = item.AccountingDocument
  
  left outer join ZEINV_JE_REV as REF on REF.AccountingDocument = item.AccountingDocument 
  and REF.CompanyCode = item.CompanyCode and REF.FiscalYear = item.FiscalYear

{

key cast( item.AccountingDocument as abap.char(10) ) as BillingDocument,
///////cast( cast( jeamt.GLAccountName as abap.char(6) ) as abap.numc(6) ) as BillingDocumentItem,
cast( cast( item.AccountingDocumentItem as abap.char(6) ) as abap.numc(6) ) as BillingDocumentItem,
cast( '' as abap.char(40) ) as itemcode,

cast( '' as abap.char(25)) as CompanyCodeName,
//cast( '' as abap.char(20)) as companygstin,
bus1.IN_GSTIdentificationNumber as companygstin,
//head.Branch as Plant,
item.Plant,
cast( p.PlantName as abap.char(30)) as PlantName,
cast( a1.CityName as abap.char(40)) as CityName,
cast( a1.DistrictName as abap.char(40)) as DistrictName,
cast( a1.PostalCode as abap.char(10)) as PostalCode,
cast( a1.StreetName as abap.char(50)) as StreetName,
cast( a1.StreetPrefixName1 as abap.char(40)) as StreetPrefixName1,
cast( a1.StreetPrefixName2 as abap.char(40)) as StreetPrefixName2,
cast( a1.StreetSuffixName1 as abap.char(40)) as StreetSuffixName1,
cast( a1.OrganizationName1 as abap.char(40)) as OrganizationName1,


//jeamt.OffsettingAccount as Customer,
jeamt.FinalOffsetAccount as Customer,
cast( jeamt.BillToGSTIN as abap.char(18)) as TaxNumber3,
cast( '' as abap.char(35)) as customerstreetname,
cast( '' as abap.char(35)) as customercity,
cast( '' as abap.char(10)) as customerpost,
cast( '' as abap.char(80)) as CustomerName,
cast( '' as abap.char(10)) as CustomerHouse,
cast( '' as abap.char(40)) as CustomerDistrict,
cast( '' as abap.char(3)) as CustomerRegion,
cast( '' as abap.char(3)) as CustomerCountry,

cast( '' as abap.char(40)) as customerSTREET1,
cast( '' as abap.char(40)) as customerSTREET2,
cast( '' as abap.char(40)) as customerSTREET3,
cast( '' as abap.char(40)) as customerSTREET4,

head.DocumentDate as invoicedate,

jeamt.paymentterms as PaymentTermsName,
//dats_add_days(
//    head.DocumentDate,
//    cast( coalesce(payc.CashDiscount2Days, 0) as abap.int4 ),
//    'FAIL'
//) as PaymentDueDate,
dats_add_days(
    head.DocumentDate,
    coalesce(payd.FinalDays, 0),
    'FAIL'
) as PaymentDueDate,



cast( reg.RegionName  as abap.char(20)) as placeofsupply,
//cast( ''  as abap.char(3)) as placeofsupply,
//case 
//    when jeamt.GLAccountName is not null
//    then jeamt.GLAccountName
//    else item.GLAccount
//end as BillingDocumentItemText,

//item.GLAccount as BillingDocumentItemText,
case
    when item.DocumentItemText is null
    then item.GLAccount
    else item.DocumentItemText
end as BillingDocumentItemText,

item.BaseUnit as uom,

cast(item.Quantity as abap.char( 30 )) as BillingQuantity,

//cast(item.AmountInCompanyCodeCurrency as abap.dec( 23, 2 )) as NetAmount,
cast(jeamt.BaseLineAmount as abap.dec( 23,2 )) as NetAmount,
item.YY1_HSN_Code_COB as hsncode,

item.BaseUnit as BillingQuantityUnit,

//abs(cast( item.AmountInCompanyCodeCurrency as abap.dec(23,2) ) ) as netpriceamount,

abs(cast( item.AmountInTransactionCurrency as abap.dec(23,2) ) ) as netpriceamount,


case
  when jeamt.CGST_Amount is null 
  then 0
  else cast( jeamt.CGST_Amount as abap.dec(23,2) )
end as cgstamount,

case
  when jeamt.IGST_Amount is null 
  then 0
  else cast( jeamt.IGST_Amount as abap.dec(23,2) )
end as igstamount,

case
  when jeamt.SGST_Amount is null 
  then 0
  else cast( jeamt.SGST_Amount as abap.dec(23,2) )
end as sgstamount,
jeamt.CGSTRate as Cgst_rate,
jeamt.IGSTRate as igst_rate,
jeamt.SGSTRate as sgst_rate,

cast( jeamt.SGSTRate as abap.dec(23,2) ) as SGSTPER,
cast( jeamt.CGSTRate as abap.dec(23,2) ) as CGSTPER,
cast( jeamt.IGSTRate as abap.dec(23,2) ) as IGSTPER,

cast( 0 as abap.dec(23,2) ) as FreightAmount,

cast(jeamt.CUSTOMERREFERENCEDATE as abap.dats) as YY1_Po_date_BDI,
//cast( '00000000' as abap.dats) as YY1_Po_date_BDI,
 jeamt.CUSTOMERREFERENCE  as YY1_PO_Num_BDI,
//cast('' as abap.char(10))
jeamt.TaxCode as taxcode,
item.TransactionCurrency,

cast(head.AccountingDocumentType as abap.char( 9 ) )as BillingDocumentType,

item.Customer as BillToCustomer,
cast( jeamt.CustomerName as abap.char(100)) as BillToName,
cast( jeamt.BillToStreet as abap.char(60)) as BillToStreet,
cast( jeamt.BillToHouseNo as abap.char(10)) as BillToHouseNo,
cast( jeamt.BillToCity as abap.char(40)) as BillToCity,
cast( jeamt.BillToDistrict as abap.char(40)) as BillToDistrict,
cast( jeamt.BillToRegion as abap.char(3)) as BillToRegion,
cast( jeamt.BillToPostalCode as abap.char(10)) as BillToPostalCode,
cast( jeamt.BillToCountry as abap.char(3)) as BillToCountry,

cast( jeamt.STREET1 as abap.char(40)) as BILLTOSTREET1,
cast( jeamt.STREET2 as abap.char(40)) as BILLTOSTREET2,
cast( jeamt.STREET3 as abap.char(40)) as BILLTOSTREET3,
cast( jeamt.STREET4 as abap.char(40)) as BILLTOSTREET4,
cast( '' as abap.char(20)) as billtogstin,

item.Customer as ShipToCustomer,

cast( '' as abap.char(40)) as ShipToName,
cast( '' as abap.char(18) ) as ShipToGSTIN,
cast( '' as abap.char(200)) as ShipToStreet,
cast( '' as abap.char(10)) as ShipToHouseNo,
cast( '' as abap.char(40)) as ShipToCity,
cast( '' as abap.char(100)) as ShipToDistrict,
cast( '' as abap.char(10)) as ShipToRegion,
cast( '' as abap.char(10)) as ShipToPostalCode,
cast( '' as abap.char(50)) as ShipToCountry,

cast( '' as abap.char(200)) as SHIPTOSTREET1,
cast( '' as abap.char(200)) as SHIPTOSTREET2,
cast( '' as abap.char(200)) as SHIPTOSTREET3,
cast( '' as abap.char(200)) as SHIPTOSTREET4,

cast( '' as abap.char(30)) as payertoCustomer,
cast( '' as abap.char(40)) as payertoName,
cast( '' as abap.char(60)) as payerToStreet,
cast('' as abap.char(10)) as payerToHouseNo,
cast( '' as abap.char(40)) as payerToCity,
cast( '' as abap.char(40)) as payerToDistrict,
cast( '' as abap.char(13)) as payerToRegion,
cast( '' as abap.char(10)) as payerPostalCode,
cast( '' as abap.char(3)) as payerCountry,

cast( '' as abap.char(40)) as payerSTREET1,
cast( '' as abap.char(40)) as payerSTREET2,
cast( '' as abap.char(40)) as payerSTREET3,
cast( '' as abap.char(40)) as payerSTREET4,

//cast(
//    substring(
//        cast( head.JournalEntryLastChangeDateTime as abap.char(21) ),
//        1,
//        15
//    )
//    as abap.dats
//) as LastChangeDateTime,
head.JournalEntryLastChangeDateTime as LastChangeDateTime,
//cast(
//    cast( head.JournalEntryLastChangeDateTime as abap.char(21) )
//    as abap.char(14)
//) as LastChangeDateTime,
//cast( head.LastChangeDate as abap.dats ) as LastChangeDateTime,

head.DocumentReferenceID as DocumentReferenceID,
//docref.FinalDocReference as DocumentReferenceID,



//cast(case when jeamt.CustomerGSTIN is null then 'B2C' else 'B2B' end as abap.char( 4 )) as SupplyType,
//jeamt.SupplyType,
cast( item.YY1_Supplytype_JEI as abap.char( 4 ) ) as SupplyType,


cast( REF.DocumentReferenceID as abap.char(16)) as F2ReferencedDocument,
cast( REF.OrginalInvoiceDate as abap.dats) as orginalinvoicedate,

cast( jeamt.tcsamt as abap.dec(23,2) ) as tcsamount,
head.CompanyCode,
head.FiscalYear,
jeamt.GLAccountName ,
cast( jtot.InvoiceTotal as abap.dec(23,2) ) as InvoiceTotal,
cs.CustomerGroup as CustomerGroup,
cgt.CustomerGroupName as CustomerGroupText,
bck.BankAccount,
bck.BankName,
bck.HouseBank,
bck.HouseBankAccount,
bck.IFSC,
REF.DocumentReferenceID as REVERSALDOCUMENTID,
REF.InvoiceReference as REVERSALDOCUMENTNO,
cast ( '' as abap.char( 40 )) as YY1_CustomerNamepo_PDH ,
cast ( '' as abap.char( 180 )) as YY1_CustomerAddresspo_PDH,
cast ( '' as abap.char(4)) as SupplyingPlant,
jeamt.ReversalReferenceDocument as invoicereversal,
cast( '' as abap.char(40))  as AnnexureMaterial,
cast( '' as abap.char(10)) as AnnexureMaterialDocumentItem,

cast( '' as abap.char(200)) as AnnexureDesc,
cast( 0  as abap.dec(23,3)) as AnnexureQty,
cast( '' as abap.unit(3))   as AnnexureUOM,
cast( '' as abap.char(20))  as AnnexureHSN,
cast( '' as abap.char(20))  as AnnexureBatch,
cast( item.AssignmentReference as abap.char(18)) as JEAssignmentReference,
cast( bus1.BusinessTypeList as abap.char(100))  as LUTNo,
head.OriginalReferenceDocument  as referencecodeyear,
cast( '' as abap.char(20)) as WBS_ELEMENT_ID,
cast( '' as abap.char(30)) as WBS_ELEMENT_NAME,
cast( '' as abap.char(50)) as WBS_ELEMENT_DESC,
cast( '' as abap.char(3)) as taxindicator

}

where
(
      ( item.AccountingDocumentType = 'DR' 
        and (item.GLAccountType = 'P' or item.GLAccountType = 'N' )
        and item.Ledger = '0L' )

   or ( item.AccountingDocumentType = 'DG'
    and ( item.GLAccountType = 'P'or item.GLAccountType = 'N' )
        and item.Ledger = '0L'  )
)




union all

select distinct from ZEINV_MIGO as m
{
key m.BillingDocument,
//m.MaterialDocumentItem as BillingDocumentItem,
cast( cast( m.MaterialDocumentItem as abap.char(6) ) as abap.numc(6) ) as BillingDocumentItem,
cast( m.itemcode as abap.char( 40 )) as itemcode,
cast( '' as abap.char(25)) as CompanyCodeName,
cast( PlantGSTIN as abap.char(18)) as companygstin,

m.Plant,
cast( PlantName as abap.char(30)) as PlantName,

cast( '' as abap.char(40)) as CityName,
cast( '' as abap.char(40)) as DistrictName,
cast( '' as abap.char(10)) as PostalCode,
cast( '' as abap.char(50)) as StreetName,
cast( '' as abap.char(40)) as StreetPrefixName1,
cast( '' as abap.char(40)) as StreetPrefixName2,
cast( '' as abap.char(40)) as StreetSuffixName1,
cast( '' as abap.char(40)) as OrganizationName1,


cast( '' as abap.char(10)) as Customer,
cast( '' as abap.char(18)) as TaxNumber3,
cast( '' as abap.char(35)) as customerstreetname,
cast( '' as abap.char(35)) as customercity,
cast( '' as abap.char(10)) as customerpost,
cast( '' as abap.char(80)) as CustomerName,
cast( '' as abap.char(10)) as CustomerHouse,
cast( '' as abap.char(40)) as CustomerDistrict,
cast( '' as abap.char(3)) as CustomerRegion,
cast( '' as abap.char(3)) as CustomerCountry,

cast( '' as abap.char(40)) as customerSTREET1,
cast( '' as abap.char(40)) as customerSTREET2,
cast( '' as abap.char(40)) as customerSTREET3,
cast( '' as abap.char(40)) as customerSTREET4,

cast( m.DocumentDate as abap.char(8)) as invoicedate,

cast( '' as abap.char(30)) as PaymentTermsName,

cast( '' as abap.char(8)) as PaymentDueDate,

cast( m.PlaceOfSupply as abap.char(20)) as placeofsupply,

m.YY1_ItemLong_Text_PRD as BillingDocumentItemText,

//cast( '' as abap.unit(3)) as uom,
m.MaterialBaseUnit as uom,
cast( m.QuantityInBaseUnit as abap.char( 30)) as BillingQuantity,
cast( 0 as abap.dec( 23, 2 )) as NetAmount,

cast( m.ConsumptionTaxCtrlCode as abap.char(16)) as hsncode,
cast( '' as abap.unit(3)) as BillingQuantityUnit,

 //m.Price  as netpriceamount,
// cast( m.Price as abap.curr(23,2) ) as netpriceamount,
//m.Price as netpriceamount,
cast( m.Price as abap.dec(15,2) ) as netpriceamount,
cast( 0 as abap.dec(23,2)) as cgstamount,
cast( 0 as abap.dec(23,2)) as igstamount,
cast( 0 as abap.dec(23,2)) as sgstamount,

cast( m.gst as abap.dec(5,2)) as Cgst_rate,
cast( 0 as abap.dec(5,2)) as igst_rate,
cast( 0 as abap.dec(5,2)) as sgst_rate,

cast( 0 as abap.dec(23,2)) as SGSTPER,
cast( 0 as abap.dec(23,2)) as CGSTPER,
cast( 0 as abap.dec(23,2)) as IGSTPER,
cast( 0 as abap.dec(23,2) ) as FreightAmount,

cast( '00000000' as abap.dats) as YY1_Po_date_BDI,
cast( '' as abap.char(10)) as YY1_PO_Num_BDI,
cast( m.TaxCode as abap.char(2)) as taxcode,

//cast( '' as abap.cuky ) as TransactionCurrency,
m.TransactionCurrency,

cast(m.BillingType as abap.char( 9 )) as BillingDocumentType,

cast( '' as abap.char(10)) as BillToCustomer,
cast( m.shipfrom  as abap.char(100)) as BillToName,
cast( m.shipfromstreet1 as abap.char(60)) as BillToStreet,
cast( m.shipfromhouse as abap.char(10)) as BillToHouseNo,
cast( m.shipfromcity as abap.char(40)) as BillToCity,
cast( m.shipfromdistrict as abap.char(40)) as BillToDistrict,
cast( m.shipfromregion as abap.char(3)) as BillToRegion,
cast( m.shipfrompostal as abap.char(10)) as BillToPostalCode,
cast( m.shipfromcountry as abap.char(3)) as BillToCountry,

cast( m.shipfromstreet1 as abap.char(40)) as BILLTOSTREET1,
cast( m.shipfromstreet2 as abap.char(40)) as BILLTOSTREET2,
cast( m.shipfromstreet3 as abap.char(40)) as BILLTOSTREET3,
cast( m.shipfromstreet4 as abap.char(40)) as BILLTOSTREET4,
cast( m.GSTIN as abap.char(20)) as billtogstin,

cast( '' as abap.char(10)) as ShipToCustomer,
cast( m.shiptoname as abap.char(60)) as ShipToName,
cast( m.GSTIN as abap.char(18)) as ShipToGSTIN,
cast( m.shiptostreetname as abap.char(200)) as ShipToStreet,
cast( m.shiptohouse as abap.char(40)) as ShipToHouseNo,
cast( m.shiptocity as abap.char(80)) as ShipToCity,
cast( m.shiptodistrict as abap.char(100)) as ShipToDistrict,
cast( m.shiptoregion as abap.char(10)) as ShipToRegion,
cast( m.shiptopostal as abap.char(10)) as ShipToPostalCode,
//cast( m.shiptocountry as abap.char(50)) as ShipToCountry,
cast( m.shiptocountry as abap.char(50)) as ShipToCountry,
cast( m.shiptostreet1 as abap.char(200)) as SHIPTOSTREET1,
cast( m.shiptostreet2 as abap.char(200)) as SHIPTOSTREET2,
cast( m.shiptostreet3 as abap.char(200)) as SHIPTOSTREET3,
cast( m.shiptostreet4 as abap.char(200)) as SHIPTOSTREET4,

cast( m.StorageLocation as abap.char(30)) as payertoCustomer,
cast( m.StorageLocationName as abap.char(40)) as payertoName,
cast( '' as abap.char(60)) as payerToStreet,
cast('' as abap.char(10)) as payerToHouseNo,
cast( '' as abap.char(40)) as payerToCity,
cast( '' as abap.char(40)) as payerToDistrict,
cast( '' as abap.char(13)) as payerToRegion,
cast( '' as abap.char(10)) as payerPostalCode,
cast( '' as abap.char(3)) as payerCountry,

cast( '' as abap.char(40)) as payerSTREET1,
cast( '' as abap.char(40)) as payerSTREET2,
cast( '' as abap.char(40)) as payerSTREET3,
cast( '' as abap.char(40)) as payerSTREET4,
//cast( m.BillingDate as abap.dats) as  LastChangeDateTime,
m.BillingDate as LastChangeDateTime,
//cast( '' as abap.dats ) as LastChangeDateTime,

cast( '' as abap.char(16)) as DocumentReferenceID,

cast('MIGO' as abap.char(4) ) as SupplyType,

cast( '' as abap.char(16)) as F2ReferencedDocument,
cast( '' as abap.dats) as orginalinvoicedate,

cast( 0 as abap.dec(23,2)) as tcsamount,

cast( m.CompanyCode as abap.char(4)) as CompanyCode,
m.FiscalYear,

cast( '' as abap.char(255)) as GLAccountName,

cast( 0 as abap.dec(23,2)) as InvoiceTotal,

cast( '' as abap.char(02)) as CustomerGroup,
cast( '' as abap.char(20)) as CustomerGroupText,
cast ('' as abap.char( 18 )) as BankAccount,
cast ('' as abap.char( 60 )) as BankName,
cast ('' as abap.char( 5 )) as HouseBank,
cast ('' as abap.char( 60 )) as HouseBankAccount,
cast ('' as abap.char( 15 )) as IFSC,
cast ('' as abap.char( 20 )) as REVERSALDOCUMENTID,
cast ('' as abap.char( 10 )) as REVERSALDOCUMENTNO,
cast ( '' as abap.char( 40 )) as YY1_CustomerNamepo_PDH ,
cast ( '' as abap.char( 180 )) as YY1_CustomerAddresspo_PDH,
cast ( '' as abap.char(4)) as SupplyingPlant,
cast ( '' as abap.char( 10 ) ) as invoicereversal,
cast( m.annexuremateial as abap.char(40))  as AnnexureMaterial,
cast( m.annexurematitem as abap.char(10)) as AnnexureMaterialDocumentItem,

cast( m.annexurematdesc as abap.char(200)) as AnnexureDesc,
cast( m.annexurequantity as abap.dec(23,3)) as AnnexureQty,
 m.annexureuom    as AnnexureUOM,
cast( m.annexurehsn as abap.char(20))  as AnnexureHSN,
cast( m.annexurebatch as abap.char(20))  as AnnexureBatch,
cast( '' as abap.char(18)) as JEAssignmentReference,
cast( '' as abap.char(100))  as LUTNo,
cast( '' as abap.char(20) ) as referencecodeyear,
cast( '' as abap.char(20)) as WBS_ELEMENT_ID,
cast( '' as abap.char(30)) as WBS_ELEMENT_NAME,
cast( '' as abap.char(50)) as WBS_ELEMENT_DESC,
cast( m.taxindicator as abap.char(3)) as taxindicator



}

union all 


select distinct  from I_BillingDocumentItem as b1
left outer join I_BillingDocument as b2 on b1.BillingDocument = b2.BillingDocument 
and b1.CompanyCode = b2.CompanyCode
left outer join I_CompanyCode as comp1 on b1.CompanyCode = comp1.CompanyCode
left outer join I_BusinessPlace as bus1 on b1.CompanyCode = bus1.CompanyCode 
and b1.Plant = bus1.BusinessPlace
left outer join I_Plant as p1 on p1.Plant = b1.Plant
left outer join I_Address_2 as a1 on p1.AddressID = a1.AddressID
left outer join I_Customer as c1 on b1.SoldToParty = c1.Customer
left outer join I_PaymentTermsText as pay1 on b2.CustomerPaymentTerms = pay1.PaymentTerms
left outer join I_ProductPlantIntlTrd as pp1 on b1.Product = pp1.Product 
and b1.Plant = pp1.Plant
left outer join ZEINV_BILL_TAXAMT as z1 on z1.BillingDocument = b1.BillingDocument 
and z1.BillingDocumentItem = b1.BillingDocumentItem
//left outer join I_BillingDocumentPartner as bdp on c1.AddressID = bdp.AddressID
// and bdp.BillingDocument = b2.BillingDocument
//left outer join I_BillingDocumentPartner as bdp on b2.BillingDocument = bdp.BillingDocument and c1.Customer = bdp.Customer
//left outer join I_BillingDocItemPartner as bdp2 on b1.BillingDocument = bdp2.BillingDocument 
//and b1.BillingDocumentItem = bdp2.BillingDocumentItem
//left outer join I_Address_2 as bp on c1.AddressID = bp.AddressID and c1.AddressSearchTerm1 = bp.AddressSearchTerm1

left outer join ZEINV_BILLADD_AG as ag
  on ag.BILLDOC = b1.BillingDocument
   and ag.PartnerFunction = 'AG'
  left outer join ZEINV_BILLADD_WE as we
  on we.BillingDocument = b1.BillingDocument
    and p1.Plant = b1.Plant
  
   and we.PartnerFunction = 'WE'
  left outer join ZEINV_BILLADD_JSTO_RE as re
  on re.BillingDocument = b1.BillingDocument
  and p1.Plant = b1.Plant
   and re.PartnerFunction = 'RE'
  left outer join ZEINV_BILLADD_JSTO as rg
  on rg.BillingDocument = b1.BillingDocument
//  and rg.PartnerFunction = 'RG'

  left outer join ZEINV_BILL_REF as f2 on b1.BillingDocument = f2.BillingDocument 
  and b1.BillingDocumentItem = f2.BillingDocumentItem 
  
 left outer join I_Product as prod on prod.Product = b1.Product 
 
 left outer join ZEINV_BILL_TOTALAMT as btot
  on btot.BillingDocument = b1.BillingDocument
  
  left outer join ZEINV_BILLPAY_DAYS as payc
  on payc.PaymentTerms = b2.CustomerPaymentTerms
  
  left outer join I_RegionText as reg
  on reg.Region = b1.Region 
  and reg.Country = b1.Country
  and reg.Language = 'E'
  
 left outer join I_CustomerSalesArea as cs
  on cs.Customer = c1.Customer
left outer join I_CustomerGroupText as cgt
  on cgt.CustomerGroup = cs.CustomerGroup
  and cgt.Language = 'E'
  
 left outer join ZEINV_PLANT_ADD as padd 
 on padd.Plant = b1.Plant 
 
    left outer join I_BusinessPlace as bp
      on p1.Plant = bp.BusinessPlace
  
left outer join I_OutboundDeliveryItem as odi
  on odi.OutboundDelivery = b1.ReferenceSDDocument
 and odi.OutboundDeliveryItem = b1.ReferenceSDDocumentItem

left outer join I_PurchaseOrderItemAPI01 as poi
  on poi.PurchaseOrder = odi.PurchaseOrder
 and poi.PurchaseOrderItem = odi.PurchaseOrderItem
 
 left outer join I_PurchaseOrderAPI01 as PO 
 on poi.PurchaseOrder = PO.PurchaseOrder
 
 left outer join ZEINV_JSTO_543 as j543
  on j543.MaterialDocument = PO.YY1_Annexure_MaterialD_PDH
  and b1.SalesDocument = PO.PurchaseOrder

left outer join I_MaterialDocumentItem_2 as mm
on b1.SalesDocument = PO.PurchaseOrder
and mm.MaterialDocument  = PO.YY1_Annexure_MaterialD_PDH

and mm.GoodsMovementType = '543'

left  outer join I_ProductPlantBasic as pp
on pp.Plant = mm.Plant
and pp.Product = mm.Material
 
 
 left outer join I_Product as product 
 on mm.Material = product.Product
//   on j543.Material = b1.Product
// and j543.Plant    = b1.Plant
//  on j543.po = PO.PurchaseOrder
// and j543.poitem = poi.PurchaseOrderItem

  
      
 

{
key b1.BillingDocument,
////m.MaterialDocumentItem as BillingDocumentItem,
cast( cast( b1.BillingDocumentItem as abap.char(6) ) as abap.numc(6) ) as BillingDocumentItem,
//cast( b1.BillingDocumentItem as abap.char(40)) as BillingDocumentItem,
cast( '' as abap.char(40) ) as itemcode,
////cast( '' as abap.char(25)) as CompanyCodeName,
comp1.CompanyCodeName,

cast( padd.IN_GSTIdentificationNumber as abap.char(18)) as companygstin,

b1.Plant,
cast( padd.PlantName as abap.char(30)) as PlantName,

cast( padd.CityName as abap.char(40)) as CityName,
cast( padd.DistrictName as abap.char(40)) as DistrictName,
cast( padd.PostalCode as abap.char(10)) as PostalCode,
cast( padd.StreetName as abap.char(50)) as StreetName,
cast( padd.StreetPrefixName1 as abap.char(40)) as StreetPrefixName1,
cast( padd.StreetPrefixName2 as abap.char(40)) as StreetPrefixName2,
cast( padd.StreetSuffixName1 as abap.char(40)) as StreetSuffixName1,
cast( padd.OrganizationName1 as abap.char(40)) as OrganizationName1,

cast( ag.Customer as abap.char(10)) as Customer,
cast( ag.TaxNumber3 as abap.char(18)) as TaxNumber3,
//cast(bp.IN_GSTIdentificationNumber as abap.char( 18 )) as TaxNumber3,
cast( ag.StreetName as abap.char(35)) as customerstreetname,
cast( ag.CityName as abap.char(35)) as customercity,
cast( ag.PostalCode as abap.char(10)) as customerpost,
cast( ag.AddresseeFullName as abap.char(80)) as CustomerName,
cast( ag.HouseNumber as abap.char(10)) as CustomerHouse,
cast( ag.DistrictName as abap.char(40)) as CustomerDistrict,
cast( reg.RegionName as abap.char(3)) as CustomerRegion,
cast( ag.Country as abap.char(3)) as CustomerCountry,

cast( ag.StreetPrefixName1 as abap.char(40)) as customerSTREET1,
cast( ag.StreetPrefixName2 as abap.char(40)) as customerSTREET2,
cast( ag.StreetSuffixName1 as abap.char(40)) as customerSTREET3,
cast( ag.StreetSuffixName2 as abap.char(40)) as customerSTREET4,

cast( b1.BillingDocumentDate as abap.char(8)) as invoicedate,

cast( payc.PaymentTerms as abap.char(30)) as PaymentTermsName,

dats_add_days(
    b1.BillingDocumentDate,
    payc.FinalDays,
    'FAIL'
) as PaymentDueDate,

cast( reg.RegionName as abap.char(20)) as placeofsupply,

case when prod.YY1_ItemLong_Text_PRD  is null
then b1.BillingDocumentItemText 
else prod.YY1_ItemLong_Text_PRD end as BillingDocumentItemText,
b1.BaseUnit as uom,
cast(b1.BillingQuantity as abap.char( 30 )) as BillingQuantity,
cast(b1.NetAmount as abap.dec( 23, 2 )) as NetAmount,

pp1.ConsumptionTaxCtrlCode as hsncode,
b1.BillingQuantityUnit as BillingQuantityUnit,

case
  when z1.ZPRO_Rate is null 
  then cast( 0 as abap.dec(23,2) )
  else cast( z1.ZPRO_Rate as abap.dec(23,2) )
end as netpriceamount,

case
  when z1.JOCG_Amount is null 
  then 0
  else cast( z1.JOCG_Amount as abap.dec(23,2) )
end as cgstamount,
case
  when z1.JOIG_Amount is null 
  then 0
  else cast( z1.JOIG_Amount as abap.dec(23,2) )
end as igstamount,
case
  when z1.JOSG_Amount is null 
  then 0
  else cast( z1.JOSG_Amount as abap.dec(23,2) )
end as sgstamount,
z1.Cgst_rate,
z1.igst_rate,
z1.sgst_rate,

case
  when z1.SGSTPER is null
       or z1.SGSTPER = ''
       or z1.SGSTPER = '%'
  then cast( 0 as abap.dec(23,2) )
  else cast( replace( z1.SGSTPER, '%', '' ) as abap.dec(23,2) )
end as SGSTPER,
case
  when z1.CGSTPER is null
       or z1.CGSTPER = ''
       or z1.CGSTPER = '%'
  then cast( 0 as abap.dec(23,2) )
  else cast( replace( z1.CGSTPER, '%', '' ) as abap.dec(23,2) )
end as CGSTPER,
case
  when z1.IGSTPER is null
       or z1.IGSTPER = ''
       or z1.IGSTPER = '%'
  then cast( 0 as abap.dec(23,2) )
  else cast( replace( z1.IGSTPER, '%', '' ) as abap.dec(23,2) )
end as IGSTPER,

cast( 0 as abap.dec(23,2) ) as FreightAmount,

case
    when b1.YY1_Po_date_BDI is not null
         and b1.YY1_Po_date_BDI <> '00000000'
    then b1.YY1_Po_date_BDI

    when PO.PurchaseOrderDate is not null
    then PO.PurchaseOrderDate

    else b1.YY1_Po_date_BDI
end as YY1_Po_date_BDI,

cast(
case
    when b1.YY1_PO_Num_BDI is not null
         and b1.YY1_PO_Num_BDI <> ''
    then b1.YY1_PO_Num_BDI

    when odi.PurchaseOrder is not null
         and odi.PurchaseOrder <> ''
    then odi.PurchaseOrder

    else b1.YY1_PO_Num_BDI
end as abap.char(20)
) as YY1_PO_Num_BDI,



//b1.YY1_Po_date_BDI,
//b1.YY1_PO_Num_BDI,
b1.TaxCode as taxcode,

b1.TransactionCurrency as TransactionCurrency,

cast(b2.BillingDocumentType as abap.char( 9 )) as BillingDocumentType,

cast( re.Customer as abap.char(10)) as BillToCustomer,
cast( re.AddresseeFullName as abap.char(100)) as BillToName,
cast( re.StreetName as abap.char(60)) as BillToStreet,
cast( re.HouseNumber as abap.char(10)) as BillToHouseNo,
cast( re.CityName as abap.char(40)) as BillToCity,
cast( re.DistrictName as abap.char(40)) as BillToDistrict,
cast( reg.RegionName as abap.char(3)) as BillToRegion,
cast( re.PostalCode as abap.char(10)) as BillToPostalCode,
cast( re.Country as abap.char(3)) as BillToCountry,

cast( re.StreetPrefixName1 as abap.char(40)) as BILLTOSTREET1,
cast( re.StreetPrefixName2 as abap.char(40)) as BILLTOSTREET2,
cast( re.StreetSuffixName1 as abap.char(40)) as BILLTOSTREET3,
cast( re.StreetSuffixName2 as abap.char(40)) as BILLTOSTREET4,
cast( re.IN_GSTIdentificationNumber as abap.char(20)) as billtogstin,

cast( we.Customer as abap.char(10)) as ShipToCustomer,
cast( we.AddresseeFullName as abap.char(40)) as ShipToName,
cast( '' as abap.char(18) ) as ShipToGSTIN,
cast( we.Street as abap.char(200)) as ShipToStreet,
cast( we.HouseNumber as abap.char(10)) as ShipToHouseNo,
cast( we.CityName as abap.char(40)) as ShipToCity,
cast( we.DistrictName as abap.char(100)) as ShipToDistrict,
cast( reg.RegionName as abap.char(10)) as ShipToRegion,
cast( we.PostalCode as abap.char(10)) as ShipToPostalCode,
cast( we.Country as abap.char(50)) as ShipToCountry,

cast( we.StreetPrefixName1 as abap.char(200)) as SHIPTOSTREET1,
cast( we.StreetPrefixName2 as abap.char(200)) as SHIPTOSTREET2,
cast( we.StreetSuffixName1 as abap.char(200)) as SHIPTOSTREET3,
cast( we.StreetSuffixName2 as abap.char(200)) as SHIPTOSTREET4,


cast( rg.SoldToParty as abap.char(30)) as payertoCustomer,
cast( rg.AddresseeFullName as abap.char(40)) as payertoName,
cast( rg.Street as abap.char(60)) as payerToStreet,
cast( rg.HouseNumber as abap.char(10)) as payerToHouseNo,
cast( rg.CityName as abap.char(40)) as payerToCity,
cast( rg.DistrictName as abap.char(40)) as payerToDistrict,
cast( reg.RegionName as abap.char(13)) as payerToRegion,
cast( rg.PostalCode as abap.char(10)) as payerPostalCode,
cast( rg.Country as abap.char(3)) as payerCountry,

cast( rg.StreetPrefixName1 as abap.char(40)) as payerSTREET1,
cast( rg.StreetPrefixName2 as abap.char(40)) as payerSTREET2,
cast( rg.StreetSuffixName1 as abap.char(40)) as payerSTREET3,
cast( rg.StreetSuffixName2 as abap.char(40)) as payerSTREET4,
//cast( m.BillingDate as abap.dats) as  LastChangeDateTime,
b2.LastChangeDateTime as LastChangeDateTime,
//cast( '' as abap.dats ) as LastChangeDateTime,

b2.DocumentReferenceID as DocumentReferenceID,



//cast(case 
//    when bp.IN_GSTIdentificationNumber is not null and bp.IN_GSTIdentificationNumber <> '' 
//    then 'B2B'
//    else 'B2C'
//end as abap.char( 4 ))
//as SupplyType,
cast( b1.YY1_Supplytype_BDI_BDI as abap.char( 4 ) ) as SupplyType,
 

f2.F2ReferencedDocument as F2ReferencedDocument,
cast( '' as abap.dats) as orginalinvoicedate,



cast( 0 as abap.dec(23,2)) as tcsamount,

b2.CompanyCode as CompanyCode,
b2.FiscalYear as FiscalYear,

cast( '' as abap.char(255)) as GLAccountName,

cast( btot.InvoiceTotal as abap.dec(23,2) ) as InvoiceTotal,

cs.CustomerGroup,
cgt.CustomerGroupName as CustomerGroupText,

cast ('' as abap.char( 18 )) as BankAccount,
cast ('' as abap.char( 60 )) as BankName,
cast ('' as abap.char( 5 )) as HouseBank,
cast ('' as abap.char( 60 )) as HouseBankAccount,
cast ('' as abap.char( 15 )) as IFSC,
cast ('' as abap.char( 20 )) as REVERSALDOCUMENTID,
cast ('' as abap.char( 10 )) as REVERSALDOCUMENTNO,
cast ( PO.YY1_CustomerNamepo_PDH as abap.char( 40 )) as YY1_CustomerNamepo_PDH ,
cast ( PO.YY1_CustomerAddresspo_PDH as abap.char( 180 )) as YY1_CustomerAddresspo_PDH,
cast ( PO.SupplyingPlant as abap.char(4)) as SupplyingPlant,
cast ( '' as abap.char( 10 ) ) as invoicereversal,

//mm.Material as AnnexureMaterial,
j543.Material as AnnexureMaterial,
j543.MaterialDocumentItem as AnnexureMaterialDocumentItem,

//mm.MaterialDocumentItem as AnnexureMaterialDocumentItem,
//product.YY1_ItemLong_Text_PRD as AnnexureDesc,
j543.MaterialDescription as AnnexureDesc,
j543.Quantity as AnnexureQty,
//mm.QuantityInEntryUnit as AnnexureQty,
j543.UOM as AnnexureUOM,
//mm.EntryUnit as AnnexureUOM,
//pp.ConsumptionTaxCtrlCode as AnnexureHSN,
j543.ConsumptionTaxCtrlCode as AnnexureHSN,
j543.Batch as AnnexureBatch,
//mm.Batch as AnnexureBatch,
cast( '' as abap.char(18)) as JEAssignmentReference,
cast( '' as abap.char(100))  as LUTNo,
cast( '' as abap.char(20) ) as referencecodeyear,
cast( b1.YY1_WBS_ELEMENT_ID_BDI as abap.char(20)) as WBS_ELEMENT_ID,
cast( b1.YY1_WBS_ELEMENT_NAME_BDI as abap.char(30)) as WBS_ELEMENT_NAME,
cast( b1.YY1_WBS_ELEMENT_DESC_BDI as abap.char(50)) as WBS_ELEMENT_DESC,
cast( '' as abap.char(3)) as taxindicator


}

where b2.BillingDocumentType = 'JSTO'
 