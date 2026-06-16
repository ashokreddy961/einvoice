@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'migo documents'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_MIGO as
 select from I_MaterialDocumentItem_2 as m
left outer join I_JournalEntryItem as je on je.ReferenceDocument = m.MaterialDocument
and je.CompanyCode = m.CompanyCode and je.Product = m.Material and je.AccountingDocumentType = 'WA'
and je.Ledger = '0L' and je.AccountingDocumentItem = '001'
left outer join I_JournalEntry as jei on jei.AccountingDocument = je.AccountingDocument and
jei.FiscalYear = je.FiscalYear and jei.CompanyCode = je.CompanyCode
left outer join I_Product as item on item.Product = m.Material
left outer join I_ProductPlantIntlTrd   as hsn on hsn.Product = m.Material
and hsn.Plant = m.Plant
left outer join I_PurchaseOrderItemAPI01  as tax on tax.PurchaseOrder = m.PurchaseOrder
 left outer join I_ProductValuationBasic  as price on price.Product = m.Material
 and price.ValuationArea = m.Plant
 and price.ValuationType = m.Batch

left outer join I_StorageLocation as fromsloc
on m.StorageLocation = fromsloc.StorageLocation
and m.Plant = fromsloc.Plant

left outer join I_Plant as fromplant
on fromsloc.Plant = fromplant.Plant
left outer join I_StorageLocationAddress as fromaddr
on fromsloc.Plant = fromaddr.Plant
and fromsloc.StorageLocation = fromaddr.StorageLocation
left outer join I_Address_2 as fromad
on fromaddr.AddressID = fromad.AddressID
left outer join I_BusinessPlace as bp
on bp.BusinessPlace = fromplant.BusinessPlace
left outer join I_Customer as cust
on m.Customer = cust.Customer
left outer join I_Address_2 as custad
on cust.AddressID = custad.AddressID

left outer join I_Address_2 as plantad
on fromplant.AddressID = plantad.AddressID

left outer join ZEINV_MIG_201 as ann
on ann.MaterialDocument = m.YY1_AnnextureDocNo_MMI

{
    key m.MaterialDocument        as BillingDocument,
    key m.MaterialDocumentYear    as FiscalYear,
    m.MaterialDocumentItem,
   // m.Material as itemcode, //ltrim( matnr, '0' ) as Material_Display
   ltrim( m.Material, '0' ) as itemcode,
   
     jei.JournalEntryLastChangeDateTime        as BillingDate,
    jei.JournalEntryLastChangeDateTime as matdocDate,
    m.CompanyCode ,
    cast( bp.IN_GSTIdentificationNumber as abap.char(20) ) as PlantGSTIN,
    
 fromsloc.StorageLocation,
 fromsloc.StorageLocationName,
 
cast( '' as abap.char(10) ) as ToStorageLocation,
cast( '' as abap.char(40) ) as ToStorageLocationName,
fromplant.PlantName,
plantad.AddressID            as PlantAddressID,
cast (plantad.AddresseeFullName as abap.char( 100 )  )  as PlantNameAddress,
cast(plantad.CityName  as abap.char( 40 )   )        as PlantCity,
cast(plantad.PostalCode as abap.char( 20 ) )          as PlantPostalCode,
cast( plantad.Street    as abap.char(40) )      as PlantStreet,
cast(plantad.StreetName   as  abap.char(100) )      as PlantStreetName,
cast(plantad.StreetPrefixName1  as abap.char(150)  ) as PlantStreet1,
cast(plantad.StreetPrefixName2  as abap.char(150)  )  as PlantStreet2,
cast(plantad.StreetSuffixName1 as abap.char(150)  )   as PlantStreet3,
cast(plantad.StreetSuffixName2 as abap.char(150)  )   as PlantStreet4,
plantad.HouseNumber          as PlantHouse,
plantad.Country              as PlantCountry,
cast(plantad.Region  as abap.char(50)  )             as PlantRegion,
cast(plantad.DistrictName   as abap.char(50)  )      as PlantDistrict,

fromad.AddressID as shipfromid,
fromad.AddresseeFullName as  shipfrom,

fromad.CityName  as shipfromcity,
fromad.PostalCode as shipfrompostal,
fromad.Street as shipfromstreet,
fromad.StreetName as shipfromstreetname,
fromad.StreetPrefixName1 as shipfromstreet1,
fromad.StreetPrefixName2 as shipfromstreet2,
fromad.StreetSuffixName1 as shipfromstreet3,
fromad.StreetSuffixName2 as shipfromstreet4,
fromad.HouseNumber    as shipfromhouse,
fromad.Country as shipfromcountry,
fromad.Region as shipfromregion,
fromad.DistrictName as shipfromdistrict,

  cast(  m.YY1_CustomerName_MMI as abap.char(80)  ) as shiptoname,
    cast(m.YY1_CustomerAddress_MMI as abap.char( 200 ) ) as shiptoadd,
  cast( '' as abap.char(80)  ) as shiptocity,
 cast(m.YY1_Customer_pincode_MMI as abap.char(20)  ) as shiptopostal,
 cast('' as abap.char(150)  )as shiptostreet,
 cast('' as abap.char(150)  )as shiptostreetname,
 cast(m.YY1_CustomerAddress_MMI as abap.char(150)  )as shiptostreet1,
 cast('' as abap.char(150)  ) as shiptostreet2,
 cast('' as abap.char(150)  ) as shiptostreet3,
 cast('' as abap.char(150)  )as shiptostreet4,
 cast('' as abap.char(150)  )    as shiptohouse,
 cast('' as abap.char(150)  ) as shiptocountry,
 cast(''  as abap.char(60)  ) as shiptoregion,
 cast('' as abap.char(80)  ) as shiptodistrict,
  cast('' as abap.char(20) )  as GSTIN,
cast('' as abap.char(50) )  as PlaceOfSupply,
   
    m.Plant,
    m.DocumentDate,
    m.GoodsMovementType, 
    m.Material,
    item.YY1_ItemLong_Text_PRD,
    hsn.ConsumptionTaxCtrlCode,
    @Semantics.quantity.unitOfMeasure :'MaterialBaseUnit'
    m.QuantityInBaseUnit,
    m.MaterialBaseUnit,
    tax.TaxCode,
    @Semantics.amount.currencyCode: 'Priceunit'
    
m.YY1_MPrice_MMI as Price, 
m.YY1_MPrice_MMIC as Priceunit,
m.YY1_MRate_MMI as gst,
m.YY1_MTAXINDICATOR_MMI as taxindicator,
//m.yy1_mt
    m.CompanyCodeCurrency as TransactionCurrency,
    ann.Material as annexuremateial,
ann.MaterialDescription as annexurematdesc,
    @Semantics.quantity.unitOfMeasure :'MaterialBaseUnit'

ann.Quantity  as annexurequantity,
ann.UOM as annexureuom,
cast( ann.ConsumptionTaxCtrlCode as abap.char(20) ) as annexurehsn,
cast( ann.MaterialDocumentItem as abap.char(6) ) as annexurematitem,
ann.Batch as annexurebatch,

cast(
    case
        when m.GoodsMovementType = '201' then '201'
        else '000'
    end as abap.numc(3)
) as BillingType,

    'No'  as EInvoice,
    'Yes' as EWayBill,
 
    'MIGO' as Source

}
where m.GoodsMovementType ='201' and m.DebitCreditCode = 'H'

union all  

 select from I_MaterialDocumentItem_2 as m
 left outer join I_Product as item on item.Product = m.Material
left outer join I_ProductPlantIntlTrd   as hsn on hsn.Product = m.Material
and hsn.Plant = m.Plant
left outer join I_PurchaseOrderItemAPI01  as tax on tax.PurchaseOrder = m.PurchaseOrder
 left outer join I_ProductValuationBasic  as price on price.Product = m.Material
 and price.ValuationArea = m.Plant
 and price.ValuationType = m.Batch
 left outer join I_MaterialDocumentHeader_2 as head
on head.MaterialDocument = m.MaterialDocument
and head.MaterialDocumentYear = m.MaterialDocumentYear
left outer join I_StorageLocation as fromsloc
on m.StorageLocation = fromsloc.StorageLocation
and m.Plant = fromsloc.Plant
left outer join I_Plant as fromplant
on fromsloc.Plant = fromplant.Plant

left outer join I_Address_2 as fromplantad
on fromplant.AddressID = fromplantad.AddressID

left outer join I_StorageLocationAddress as fromaddr
on fromsloc.Plant = fromaddr.Plant
and fromsloc.StorageLocation = fromaddr.StorageLocation
left outer join I_Address_2 as fromad
on fromaddr.AddressID = fromad.AddressID
left outer join I_BusinessPlace as bp
on bp.BusinessPlace = fromplant.BusinessPlace
left outer join I_StorageLocation as tosloc
on head.IssuingOrReceivingStorageLoc = tosloc.StorageLocation
and m.Plant = tosloc.Plant
left outer join I_StorageLocationAddress as toaddr
on tosloc.Plant = toaddr.Plant
and tosloc.StorageLocation = toaddr.StorageLocation
left outer join I_Address_2 as toad
on toaddr.AddressID = toad.AddressID
//left outer join I_JournalEntryItem as je on je.InvoiceReference = m.MaterialDocument
//and je.CompanyCode = m.CompanyCode and je.Product = m.Material and je.AccountingDocumentType = 'WA'
//and je.Ledger = '0L'
//inner join I_JournalEntry as jei on jei.AccountingDocument = je.AccountingDocument and
//jei.FiscalYear = je.FiscalYear and jei.CompanyCode = je.CompanyCode
 
//left outer join I_MaterialDocumentHeader_2 as head
//on m.MaterialDocument = head.MaterialDocument
{
    key m.MaterialDocument        as BillingDocument,
    key m.MaterialDocumentYear    as FiscalYear,
    m.MaterialDocumentItem,
   //  m.Material as itemcode,
   ltrim( m.Material, '0' ) as itemcode,
   
        cast( '000000000000000' as abap.dec(15) ) as BillingDate,
      cast( '000000000000000' as abap.dec(15)) as matdocDate,
    m.CompanyCode,
 cast( bp.IN_GSTIdentificationNumber  as abap.char(20) ) as PlantGSTIN,
fromsloc.StorageLocation,
fromsloc.StorageLocationName,

head.IssuingOrReceivingStorageLoc as ToStorageLocation,
//tosloc.StorageLocationName as ToStorageLocationName,
'' as ToStorageLocationName,
fromplant.PlantName,
 fromplantad.AddressID as PlantAddressID,
    fromplantad.AddresseeFullName as PlantNameAddress,
    fromplantad.CityName as PlantCity,
    fromplantad.PostalCode as PlantPostalCode,
    fromplantad.Street as PlantStreet,
    fromplantad.StreetName as PlantStreetName,
    fromplantad.StreetPrefixName1 as PlantStreet1,
    fromplantad.StreetPrefixName2 as PlantStreet2,
    fromplantad.StreetSuffixName1 as PlantStreet3,
    fromplantad.StreetSuffixName2 as PlantStreet4,
    fromplantad.HouseNumber as PlantHouse,
    fromplantad.Country as PlantCountry,
    fromplantad.Region as PlantRegion,
    fromplantad.DistrictName as PlantDistrict,

    fromad.AddressID as shipfromid,
    fromad.AddresseeFullName as shipfrom,
//tosloc.StorageLocationName as shipfrom,
    fromad.CityName as shipfromcity,
    fromad.PostalCode as shipfrompostal,
    fromad.Street as shipfromstreet,
    fromad.StreetName as shipfromstreetname,
    fromad.StreetPrefixName1 as shipfromstreet1,
    fromad.StreetPrefixName2 as shipfromstreet2,
    fromad.StreetSuffixName1 as shipfromstreet3,
    fromad.StreetSuffixName2 as shipfromstreet4,
    fromad.HouseNumber as shipfromhouse,
    fromad.Country as shipfromcountry,
    fromad.Region as shipfromregion,
    fromad.DistrictName as shipfromdistrict,
    
//head.IssuingOrReceivingStorageLoc as ToStorageLocation,
tosloc.StorageLocationName as shiptoname,

   cast( '' as abap.char(40) ) as shiptoadd,
  toad.CityName as shiptocity,
    toad.PostalCode as shiptopostal,
    toad.Street as shiptostreet,
    toad.StreetName as shiptostreetname,
    toad.StreetPrefixName1 as shiptostreet1,
    toad.StreetPrefixName2 as shiptostreet2,
    toad.StreetSuffixName1 as shiptostreet3,
    toad.StreetSuffixName2 as shiptostreet4,
    toad.HouseNumber as shiptohouse,
    toad.Country as shiptocountry,
    toad.Region as shiptoregion,
    toad.DistrictName as shiptodistrict,
        cast('' as abap.char(20) ) as GSTIN,
cast('' as abap.char(50) ) as PlaceOfSupply,
    m.Plant,
    m.DocumentDate,
    m.GoodsMovementType,
    m.Material,
         item.YY1_ItemLong_Text_PRD, 
      hsn.ConsumptionTaxCtrlCode,
//       @Semantics.quantity.unitOfMeasure :'MaterialBaseUnit'
    m.QuantityInBaseUnit,
    m.MaterialBaseUnit,
    tax.TaxCode,
  m.YY1_MPrice_MMI as Price, 
  m.YY1_MPrice_MMIC as Priceunit,
  m.YY1_MRate_MMI as gst,
 m.YY1_MTAXINDICATOR_MMI as taxindicator,
          m.CompanyCodeCurrency as TransactionCurrency,
    
//tosloc.StorageLocationName as ToStorageLocationName,
//bp.IN_GSTIdentificationNumber as PlantGSTIN,
//cast( '' as abap.char(10) ) as Customer,
//cast( '' as abap.char(80) ) as BPName,
//'' as  GSTIN,
cast( '' as abap.char(18) ) as annexuremateial,
cast( '' as abap.char(100) ) as annexurematdesc,
cast( 0 as abap.quan(13,3) ) as annexurequantity,
cast( '' as abap.unit(3) ) as annexureuom,
cast( '' as abap.char(20) ) as annexurehsn,
cast('' as abap.char(6)) as annexurematitem,
cast( '' as abap.char(10)) as annexurebatch,

cast(
    case
        when m.GoodsMovementType = '311' then '311'
        else '000'
    end as abap.numc(3)
) as BillingType,

    'No'  as EInvoice,
    'Yes' as EWayBill,
 
    'MIGO' as Source

}
where  m.GoodsMovementType = '311' and m.DebitCreditCode = 'H'

union all  

select from I_MaterialDocumentItem_2 as m
left outer join I_MaterialDocumentHeader_2 as mathead
 on m.MaterialDocument = mathead.MaterialDocument 
 and m.MaterialDocumentYear = mathead.MaterialDocumentYear

left outer join I_Product as item
on item.Product = m.Material

left outer join I_ProductPlantIntlTrd as hsn
on hsn.Product = m.Material
and hsn.Plant = m.Plant

left outer join I_PurchaseOrderItemAPI01 as tax
on tax.PurchaseOrder = m.PurchaseOrder

left outer join I_ProductValuationBasic as price
on price.Product = m.Material
and price.ValuationArea = m.Plant
and price.ValuationType = m.Batch

left outer join ZEINV_MIGO_RE as sup
on sup.Supplier = m.Supplier

left outer join I_StorageLocation as fromsloc
on mathead.StorageLocation = fromsloc.StorageLocation
and mathead.Plant = fromsloc.Plant

left outer join I_Plant as fromplant on fromsloc.Plant = fromplant.Plant

left outer join I_Address_2 as plantad on fromplant.AddressID = plantad.AddressID
left outer join I_StorageLocationAddress as fromaddr
on fromsloc.Plant = fromaddr.Plant
and fromsloc.StorageLocation = fromaddr.StorageLocation
left outer join I_Address_2 as fromad on fromaddr.AddressID = fromad.AddressID
left outer join I_BusinessPlace as bp on bp.BusinessPlace = fromplant.BusinessPlace

{
    key m.MaterialDocument as BillingDocument,
    key m.MaterialDocumentYear as FiscalYear,

    m.MaterialDocumentItem,
    // m.Material as itemcode, //ltrim( m.Material, '0' ) as itemcode,
ltrim( m.Material, '0' ) as itemcode,
    cast( '000000000000000' as abap.dec(15) ) as BillingDate,
    cast( '000000000000000' as abap.dec(15) ) as matdocDate,

    m.CompanyCode,
  cast(  bp.IN_GSTIdentificationNumber as abap.char(20) ) as PlantGSTIN,
    
  fromsloc.StorageLocation,
fromsloc.StorageLocationName,

cast( '' as abap.char(10) ) as ToStorageLocation,
cast( '' as abap.char(40) ) as ToStorageLocationName,

fromplant.PlantName,
    plantad.AddressID as PlantAddressID,
    plantad.AddresseeFullName as PlantNameAddress,
    plantad.CityName as PlantCity,
    plantad.PostalCode as PlantPostalCode,
    plantad.Street as PlantStreet,
    plantad.StreetName as PlantStreetName,
    plantad.StreetPrefixName1 as PlantStreet1,
    plantad.StreetPrefixName2 as PlantStreet2,
    plantad.StreetSuffixName1 as PlantStreet3,
    plantad.StreetSuffixName2 as PlantStreet4,
    plantad.HouseNumber as PlantHouse,
    plantad.Country as PlantCountry,
    plantad.Region as PlantRegion,
    plantad.DistrictName as PlantDistrict,
    
    
    fromad.AddressID as shipfromid,
    fromad.AddresseeFullName as shipfrom,

    fromad.CityName as shipfromcity,
    fromad.PostalCode as shipfrompostal,
    fromad.Street as shipfromstreet,
    fromad.StreetName as shipfromstreetname,
    fromad.StreetPrefixName1 as shipfromstreet1,
    fromad.StreetPrefixName2 as shipfromstreet2,
    fromad.StreetSuffixName1 as shipfromstreet3,
    fromad.StreetSuffixName2 as shipfromstreet4,
    fromad.HouseNumber as shipfromhouse,
    fromad.Country as shipfromcountry,
    fromad.Region as shipfromregion,
    fromad.DistrictName as shipfromdistrict,
    
    
       sup.AddresseeFullName as shiptoname,

    cast( '' as abap.char(40) ) as shiptoadd,

    sup.CityName as shiptocity,
    sup.PostalCode as shiptopostal,
    sup.Street as shiptostreet,
    sup.StreetName as shiptostreetname,
    sup.StreetPrefixName1 as shiptostreet1,
    sup.StreetPrefixName2 as shiptostreet2,
    sup.StreetSuffixName1 as shiptostreet3,
    sup.StreetSuffixName2 as shiptostreet4,
    sup.HouseNumber as shiptohouse,
    sup.Country as shiptocountry,
    sup.Region as shiptoregion,
    sup.DistrictName as shiptodistrict,
    sup.TaxNumber3 as GSTIN,
    sup.Region as PlaceOfSupply,
    
      m.Plant,
    m.DocumentDate,
    m.GoodsMovementType,
    m.Material,

    item.YY1_ItemLong_Text_PRD,

    hsn.ConsumptionTaxCtrlCode,

//    @Semantics.quantity.unitOfMeasure : 'MaterialBaseUnit'
    m.QuantityInBaseUnit,

    m.MaterialBaseUnit,

    tax.TaxCode,

    m.YY1_MPrice_MMI as Price,
    m.YY1_MPrice_MMIC as Priceunit,
    m.YY1_MRate_MMI as gst,
m.YY1_MTAXINDICATOR_MMI as taxindicator,
    m.CompanyCodeCurrency as TransactionCurrency,
    cast( '' as abap.char(18) ) as annexuremateial,
cast( '' as abap.char(100) ) as annexurematdesc,
cast( 0 as abap.quan(13,3) ) as annexurequantity,
cast( '' as abap.unit(3) ) as annexureuom,
cast( '' as abap.char(20) ) as annexurehsn,
cast('' as abap.char(6)) as annexurematitem,
cast( '' as abap.char(10)) as annexurebatch,

    cast(
        case
            when m.GoodsMovementType = '541'
            then '541'
            else '000'
        end as abap.numc(3)
    ) as BillingType,
        
        'No' as EInvoice,
    'Yes' as EWayBill,

    'MIGO' as Source
    


}

where m.GoodsMovementType = '541'
and m.DebitCreditCode = 'S'

union all  

 select from I_MaterialDocumentItem_2 as m
 left outer join I_Product as item on item.Product = m.Material
 left outer join I_ProductPlantIntlTrd   as hsn on hsn.Product = m.Material
and hsn.Plant = m.Plant
left outer join I_PurchaseOrderItemAPI01  as tax on tax.PurchaseOrder = m.PurchaseOrder
 left outer join I_ProductValuationBasic  as price on price.Product = m.Material
 and price.ValuationArea = m.Plant
 and price.ValuationType = m.Batch
 left outer join ZEINV_MIGO_RE as sup on sup.Supplier = m.Supplier
//left outer join I_JournalEntryItem as je on je.InvoiceReference = m.MaterialDocument
//and je.CompanyCode = m.CompanyCode and je.Product = m.Material and je.AccountingDocumentType = 'WA'
//and je.Ledger = '0L'
//inner join I_JournalEntry as jei on jei.AccountingDocument = je.AccountingDocument and
//jei.FiscalYear = je.FiscalYear and jei.CompanyCode = je.CompanyCode
 
//left outer join I_MaterialDocumentHeader_2 as head
//on m.MaterialDocument = head.MaterialDocument

{
    key m.MaterialDocument as BillingDocument,
    key m.MaterialDocumentYear as FiscalYear,

    m.MaterialDocumentItem,
    // m.Material as itemcode, //ltrim( m.Material, '0' ) as itemcode,
ltrim( m.Material, '0' ) as itemcode,
    cast( '000000000000000' as abap.dec(15) ) as BillingDate,
    cast( '000000000000000' as abap.dec(15) ) as matdocDate,

    m.CompanyCode,
  cast(  '' as abap.char(20) ) as PlantGSTIN,
    
  '' as StorageLocation,
'' as StorageLocationName,

cast( '' as abap.char(10) ) as ToStorageLocation,
cast( '' as abap.char(40) ) as ToStorageLocationName,

'' as PlantName,
    '' as    PlantAddressID,
    '' as   PlantNameAddress,
    '' as   PlantCity,
    '' as   PlantPostalCode,
    '' as   PlantStreet,
    '' as   PlantStreetName,
    '' as  PlantStreet1,
    '' as  PlantStreet2,
    '' as  PlantStreet3,
    '' as  PlantStreet4,
    '' as  PlantHouse,
    '' as  PlantCountry,
    '' as PlantRegion,
    ''   as PlantDistrict,
    
    
    '' as shipfromid,
    '' as shipfrom,

    '' as shipfromcity,
    '' as shipfrompostal,
    '' as shipfromstreet,
 '' as shipfromstreetname,
 '' as shipfromstreet1,
    '' as shipfromstreet2,
    ''as shipfromstreet3,
 '' as shipfromstreet4,
  '' as shipfromhouse,
  '' as shipfromcountry,
   ''  as shipfromregion,
 ''as shipfromdistrict,
    
    
       sup.AddresseeFullName as shiptoname,

    cast( '' as abap.char(40) ) as shiptoadd,

    sup.CityName as shiptocity,
    sup.PostalCode as shiptopostal,
    sup.Street as shiptostreet,
    sup.StreetName as shiptostreetname,
    sup.StreetPrefixName1 as shiptostreet1,
    sup.StreetPrefixName2 as shiptostreet2,
    sup.StreetSuffixName1 as shiptostreet3,
    sup.StreetSuffixName2 as shiptostreet4,
    sup.HouseNumber as shiptohouse,
    sup.Country as shiptocountry,
    sup.Region as shiptoregion,
    sup.DistrictName as shiptodistrict,
    sup.TaxNumber3 as GSTIN,
    sup.Region as PlaceOfSupply,
    
      m.Plant,
    m.DocumentDate,
    m.GoodsMovementType,
    m.Material,

    item.YY1_ItemLong_Text_PRD,

    hsn.ConsumptionTaxCtrlCode,

//    @Semantics.quantity.unitOfMeasure : 'MaterialBaseUnit'
    m.QuantityInBaseUnit,

    m.MaterialBaseUnit,

    tax.TaxCode,

    m.YY1_MPrice_MMI as Price,
    m.YY1_MPrice_MMIC as Priceunit,
    m.YY1_MRate_MMI as gst,
m.YY1_MTAXINDICATOR_MMI as taxindicator,
    m.CompanyCodeCurrency as TransactionCurrency,
    cast( '' as abap.char(18) ) as annexuremateial,
cast( '' as abap.char(100) ) as annexurematdesc,
cast( 0 as abap.quan(13,3) ) as annexurequantity,
cast( '' as abap.unit(3) ) as annexureuom,
cast( '' as abap.char(20) ) as annexurehsn,
cast('' as abap.char(6)) as annexurematitem,
cast( '' as abap.char(10)) as annexurebatch,

    cast(
        case
            when m.GoodsMovementType = '541'
            then '541'
            else '000'
        end as abap.numc(3)
    ) as BillingType,
        
        'No' as EInvoice,
    'Yes' as EWayBill,

    'MIGO' as Source
    


}

where m.GoodsMovementType = '542'
and m.DebitCreditCode = 'H'









//union all  
//
// select from I_MaterialDocumentItem_2 as m
// left outer join I_Product as item on item.Product = m.Material
// left outer join I_ProductPlantIntlTrd   as hsn on hsn.Product = m.Material
//and hsn.Plant = m.Plant
//left outer join I_PurchaseOrderItemAPI01  as tax on tax.PurchaseOrder = m.PurchaseOrder
// left outer join I_ProductValuationBasic  as price on price.Product = m.Material
// and price.ValuationArea = m.Plant
// and price.ValuationType = m.Batch
// left outer join ZEINV_MIGO_RE as sup on sup.Supplier = m.Supplier
// 
// left outer join I_StorageLocation as fromsloc
//on m.StorageLocation = fromsloc.StorageLocation
//and m.Plant = fromsloc.Plant
//left outer join I_Plant as fromplant
//on fromsloc.Plant = fromplant.Plant
//left outer join I_StorageLocationAddress as fromaddr
//on fromsloc.Plant = fromaddr.Plant
//and fromsloc.StorageLocation = fromaddr.StorageLocation
//left outer join I_Address_2 as fromad
//on fromaddr.AddressID = fromad.AddressID
//left outer join I_BusinessPlace as bp
//on bp.BusinessPlace = fromplant.BusinessPlace
////left outer join I_JournalEntryItem as je on je.InvoiceReference = m.MaterialDocument
////and je.CompanyCode = m.CompanyCode and je.Product = m.Material and je.AccountingDocumentType = 'WA'
////and je.Ledger = '0L'
////inner join I_JournalEntry as jei on jei.AccountingDocument = je.AccountingDocument and
////jei.FiscalYear = je.FiscalYear and jei.CompanyCode = je.CompanyCode
// 
////left outer join I_MaterialDocumentHeader_2 as head
////on m.MaterialDocument = head.MaterialDocument
//{
//    key m.MaterialDocument        as BillingDocument,
//    key m.MaterialDocumentYear    as FiscalYear,
//    m.MaterialDocumentItem,
//    m.CompanyCode,
//    sup.AddresseeFullName,
//     sup.CityNumber,
//    sup.CityName,
//    sup.DistrictName,
//    sup.VillageName,
//    sup.PostalCode,
//    sup.CompanyPostalCode,
//    sup.Street,
//    sup.StreetName,
//    sup.StreetAddrNonDeliverableReason,
//    sup.StreetPrefixName1,
//    sup.StreetPrefixName2,
//    sup.StreetSuffixName1,
//    sup.StreetSuffixName2,
//    sup.HouseNumber,
//    sup.HouseNumberSupplementText,
//    sup.Building,
//    sup.Floor,
//    sup.RoomNumber,
//    sup.Country,
//    sup.Region,
//cast( '000000000000000' as abap.dec(15) ) as BillingDate,
// cast( '000000000000000' as abap.dec(15) ) as matdocDate,
// 
//  //  jei.JournalEntryLastChangeDateTime        as BillingDate,
//    m.Plant,
//   // m.StorageLocation,
//   m.DocumentDate,
//    m.GoodsMovementType, 
//    m.Material,
//    item.YY1_ItemLong_Text_PRD, 
//    hsn.ConsumptionTaxCtrlCode, 
//    m.QuantityInBaseUnit,
//    m.MaterialBaseUnit,
//    tax.TaxCode,
// //   cast(price.MovingAveragePrice as abap.dec(23,2)) as Price,
//m.YY1_MPrice_MMIC as Price,
////    case
////        
////        when m.GoodsMovementType = '541' then '541'
////        else ''
////    end as BillingType,
//cast(
//    case
//        when m.GoodsMovementType = '541' then '541'
//        else '000'
//    end as abap.numc(3)
//) as BillingType, 
//fromsloc.StorageLocation,
//fromsloc.StorageLocationName,
//
//fromplant.PlantName,
//
//fromad.StreetPrefixName2 as FromStreetName,
//fromad.CityName as FromCityName,
//fromad.AddresseeFullName as fromname,
// fromad.Region as FromState,
//fromad.PostalCode as FromPostalCode,
//cast( '' as abap.char(10) ) as ToStorageLocation,
//cast( '' as abap.char(40) ) as ToStorageLocationName,
//
//bp.IN_GSTIdentificationNumber as PlantGSTIN,
//cast( '' as abap.char(10) ) as Customer,
//sup.AddresseeFullName as BPName,
//sup.TaxNumber3 as GSTIN,
//sup.StreetPrefixName2 as ToStreetName,
//sup.CityName as ToCityName,
//sup.AddresseeFullName as ToName,
//sup.Region as ToState,
//sup.PostalCode as ToPostalCode,
//
//    'No'  as EInvoice,
//    'Yes' as EWayBill,
// 
//    'MIGO' as Source,
//      m.CompanyCodeCurrency as TransactionCurrency
//}
//where  m.GoodsMovementType = '541' and m.DebitCreditCode = 'S'


//
//union all  
//
// select from I_MaterialDocumentItem_2 as m
// left outer join I_Product as item on item.Product = m.Material
// left outer join I_ProductPlantIntlTrd   as hsn on hsn.Product = m.Material
//and hsn.Plant = m.Plant
//left outer join I_PurchaseOrderItemAPI01  as tax on tax.PurchaseOrder = m.PurchaseOrder
// left outer join I_ProductValuationBasic  as price on price.Product = m.Material
// and price.ValuationArea = m.Plant
// and price.ValuationType = m.Batch
// left outer join ZEINV_MIGO_RE as sup on sup.Supplier = m.Supplier
////left outer join I_JournalEntryItem as je on je.InvoiceReference = m.MaterialDocument
////and je.CompanyCode = m.CompanyCode and je.Product = m.Material and je.AccountingDocumentType = 'WA'
////and je.Ledger = '0L'
////inner join I_JournalEntry as jei on jei.AccountingDocument = je.AccountingDocument and
////jei.FiscalYear = je.FiscalYear and jei.CompanyCode = je.CompanyCode
// 
////left outer join I_MaterialDocumentHeader_2 as head
////on m.MaterialDocument = head.MaterialDocument
//{
//    key m.MaterialDocument        as BillingDocument,
//    key m.MaterialDocumentYear    as FiscalYear,
//    m.MaterialDocumentItem,
//    m.CompanyCode,
//     sup.AddresseeFullName,
//      sup.CityNumber,
//    sup.CityName,
//    sup.DistrictName,
//    sup.VillageName,
//    sup.PostalCode,
//    sup.CompanyPostalCode,
//    sup.Street,
//    sup.StreetName,
//    sup.StreetAddrNonDeliverableReason,
//    sup.StreetPrefixName1,
//    sup.StreetPrefixName2,
//    sup.StreetSuffixName1,
//    sup.StreetSuffixName2,
//    sup.HouseNumber,
//    sup.HouseNumberSupplementText,
//    sup.Building,
//    sup.Floor,
//    sup.RoomNumber,
//    sup.Country,
//    sup.Region,
// cast( '000000000000000' as abap.dec(15) ) as BillingDate,
// cast( '000000000000000' as abap.dec(15) ) as matdocDate,
//  //  jei.JournalEntryLastChangeDateTime        as BillingDate,
//    m.Plant,
//   // m.StorageLocation,
//   m.DocumentDate,
//    m.GoodsMovementType,
//    m.Material,
//    item.YY1_ItemLong_Text_PRD,  
//    hsn.ConsumptionTaxCtrlCode,
//    m.QuantityInBaseUnit,
//    m.MaterialBaseUnit, 
//    tax.TaxCode,
//   // cast(price.MovingAveragePrice as abap.dec(23,2)) as Price,
// //price.MovingAveragePrice as Price,
//m.YY1_MPrice_MMIC as Price,
//cast(
//    case
//        when m.GoodsMovementType = '542' then '542'
//        else '000'
//    end as abap.numc(3)
//) as BillingType, 
//cast( '' as abap.char(10) ) as StorageLocation,
//cast( '' as abap.char(40) ) as StorageLocationName,
//cast( '' as abap.char(40) ) as PlantName,
//
//cast( '' as abap.char(100) ) as FromStreetName,
//cast( '' as abap.char(40) ) as FromCityName,
//cast( '' as abap.char(80) ) as FromName,
//cast( '' as abap.char(10) ) as FromState,
//cast( '' as abap.char(10) ) as FromPostalCode,
//cast( '' as abap.char(10) ) as ToStorageLocation,
//cast( '' as abap.char(40) ) as ToStorageLocationName,
//cast( '' as abap.char(20) ) as PlantGSTIN,
//cast( '' as abap.char(10) ) as Customer,
//
//cast( '' as abap.char(80) ) as BPName,
//cast( '' as abap.char(20) ) as GSTIN,
//
//cast( '' as abap.char(80) ) as ToStreetName,
//cast( '' as abap.char(40) ) as ToCityName,
//cast( '' as abap.char(80) ) as ToName,
//cast( '' as abap.char(10) ) as ToState,
//cast( '' as abap.char(10) ) as ToPostalCode,
//    'No'  as EInvoice,
//    'Yes' as EWayBill,
// 
//    'MIGO' as Source,
//      m.CompanyCodeCurrency as TransactionCurrency
//}
//where m.GoodsMovementType = '542'  and m.DebitCreditCode = 'H'



//@AbapCatalog.viewEnhancementCategory: [#NONE]
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'migo documents'
//@Metadata.ignorePropagatedAnnotations: true
//define view entity ZEINV_MIGO as select from I_MaterialDocumentItem_2 as m
//left outer join I_JournalEntryItem as je on je.ReferenceDocument = m.MaterialDocument
//and je.CompanyCode = m.CompanyCode and je.Product = m.Material and je.AccountingDocumentType = 'WA'
//and je.Ledger = '0L'
//inner join I_JournalEntry as jei on jei.AccountingDocument = je.AccountingDocument and
//jei.FiscalYear = je.FiscalYear and jei.CompanyCode = je.CompanyCode
// 
////left outer join I_MaterialDocumentHeader_2 as head
////on m.MaterialDocument = head.MaterialDocument
//{
//    key m.MaterialDocument        as BillingDocument,
//    key m.MaterialDocumentYear    as FiscalYear,
//    m.MaterialDocumentItem,
// 
//    jei.JournalEntryLastChangeDateTime        as BillingDate,
//    m.Plant,
//    m.StorageLocation,
//    m.DocumentDate,
//    m.GoodsMovementType,   // <-- 201, 311
// 
////    case
////        when m.GoodsMovementType = '201' then '201'
////        
////        else ''
////    end as BillingType,
//cast(
//    case
//        when m.GoodsMovementType = '201' then '201'
//        else '000'
//    end as abap.numc(3)
//) as BillingType,
// 
//    'No'  as EInvoice,
//    'Yes' as EWayBill,
// 
//    'MIGO' as Source
//}
//where( m.GoodsMovementType ='201' )
//
//union all  
//
// select from I_MaterialDocumentItem_2 as m
////left outer join I_JournalEntryItem as je on je.InvoiceReference = m.MaterialDocument
////and je.CompanyCode = m.CompanyCode and je.Product = m.Material and je.AccountingDocumentType = 'WA'
////and je.Ledger = '0L'
////inner join I_JournalEntry as jei on jei.AccountingDocument = je.AccountingDocument and
////jei.FiscalYear = je.FiscalYear and jei.CompanyCode = je.CompanyCode
// 
////left outer join I_MaterialDocumentHeader_2 as head
////on m.MaterialDocument = head.MaterialDocument
//{
//    key m.MaterialDocument        as BillingDocument,
//    key m.MaterialDocumentYear    as FiscalYear,
//    m.MaterialDocumentItem,
// cast( '000000000000000' as abap.dec(15) ) as BillingDate,
// 
//  //  jei.JournalEntryLastChangeDateTime        as BillingDate,
//    m.Plant,
//    m.StorageLocation,
//   m.DocumentDate,
//    m.GoodsMovementType,   // <-- 201, 311
// 
////    case
////        
////        when m.GoodsMovementType = '311' then '311'
////        else ''
////    end as BillingType,
//cast(
//    case
//        when m.GoodsMovementType = '311' then '311'
//        else '000'
//    end as abap.numc(3)
//) as BillingType,
// 
//    'No'  as EInvoice,
//    'Yes' as EWayBill,
// 
//    'MIGO' as Source
//}
//where(  m.GoodsMovementType = '311')
//
//union all  
//
// select from I_MaterialDocumentItem_2 as m
////left outer join I_JournalEntryItem as je on je.InvoiceReference = m.MaterialDocument
////and je.CompanyCode = m.CompanyCode and je.Product = m.Material and je.AccountingDocumentType = 'WA'
////and je.Ledger = '0L'
////inner join I_JournalEntry as jei on jei.AccountingDocument = je.AccountingDocument and
////jei.FiscalYear = je.FiscalYear and jei.CompanyCode = je.CompanyCode
// 
////left outer join I_MaterialDocumentHeader_2 as head
////on m.MaterialDocument = head.MaterialDocument
//{
//    key m.MaterialDocument        as BillingDocument,
//    key m.MaterialDocumentYear    as FiscalYear,
//    m.MaterialDocumentItem,
// cast( '000000000000000' as abap.dec(15) ) as BillingDate,
// 
//  //  jei.JournalEntryLastChangeDateTime        as BillingDate,
//    m.Plant,
//    m.StorageLocation,
//   m.DocumentDate,
//    m.GoodsMovementType,   // <-- 201, 311
// 
////    case
////        
////        when m.GoodsMovementType = '541' then '541'
////        else ''
////    end as BillingType,
//cast(
//    case
//        when m.GoodsMovementType = '541' then '541'
//        else '000'
//    end as abap.numc(3)
//) as BillingType, 
//    'No'  as EInvoice,
//    'Yes' as EWayBill,
// 
//    'MIGO' as Source
//}
//where(  m.GoodsMovementType = '541')
//
//union all  
//
// select from I_MaterialDocumentItem_2 as m
////left outer join I_JournalEntryItem as je on je.InvoiceReference = m.MaterialDocument
////and je.CompanyCode = m.CompanyCode and je.Product = m.Material and je.AccountingDocumentType = 'WA'
////and je.Ledger = '0L'
////inner join I_JournalEntry as jei on jei.AccountingDocument = je.AccountingDocument and
////jei.FiscalYear = je.FiscalYear and jei.CompanyCode = je.CompanyCode
// 
////left outer join I_MaterialDocumentHeader_2 as head
////on m.MaterialDocument = head.MaterialDocument
//{
//    key m.MaterialDocument        as BillingDocument,
//    key m.MaterialDocumentYear    as FiscalYear,
//    m.MaterialDocumentItem,
// cast( '000000000000000' as abap.dec(15) ) as BillingDate,
// 
//  //  jei.JournalEntryLastChangeDateTime        as BillingDate,
//    m.Plant,
//    m.StorageLocation,
//   m.DocumentDate,
//    m.GoodsMovementType,   
// 
//cast(
//    case
//        when m.GoodsMovementType = '542' then '542'
//        else '000'
//    end as abap.numc(3)
//) as BillingType, 
//    'No'  as EInvoice,
//    'Yes' as EWayBill,
// 
//    'MIGO' as Source
//}
//where(  m.GoodsMovementType = '542')
//
//
//
//
//
//









 
 