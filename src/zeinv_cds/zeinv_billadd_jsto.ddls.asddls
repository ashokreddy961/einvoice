@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'billing document JSTO address'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZEINV_BILLADD_JSTO
  as select from I_BillingDocumentItem as bd

  left outer join I_OutboundDeliveryItem as odi
    on odi.OutboundDelivery = bd.ReferenceSDDocument   
    and odi.OutboundDeliveryItem  = bd.ReferenceSDDocumentItem
    
    
      left outer join I_OutboundDelivery as od
    on od.OutboundDelivery = odi.OutboundDelivery

  left outer join I_StorageLocation as sl
    on sl.StorageLocation = odi.StorageLocation
    
     left outer join I_StorageLocationAddress as sla
    on sla.StorageLocation = odi.StorageLocation
   and sla.Plant = odi.Plant
   
     left outer join I_Address_2 as add
    on add.AddressID   = sla.AddressID
    
    left outer join  I_Plant as p 
    on p.Plant = sl.Plant


    
    left outer join I_BusinessPlace as bp
     on p.Plant = bp.BusinessPlace
{
    key bd.BillingDocument,
    add.AddressID,
    add.AddresseeFullName,
    add.OrganizationName1,
    add.Street,
    add.HouseNumber,
    add.StreetName,
    add.CityName,
    add.DistrictName,
    add.PostalCode,
    add.Region,
    add.Country,
    bp.IN_GSTIdentificationNumber,
    sl.StorageLocationName as SoldToParty,
     add.StreetPrefixName1,
        add.StreetPrefixName2,
        add.StreetSuffixName1,
        add.StreetSuffixName2
      
    
}












//
//define view entity ZEINV_BILLADD_JSTO as select from  I_BillingDocument as bd
//
//    left outer join I_Plant as p
//      on p.Plant = bd.SoldToParty
//
//    left outer join I_Address_2 as add
//      on add.AddressID = p.AddressID
//
//    left outer join I_BusinessPlace as bp
//      on p.Plant = bp.BusinessPlace
//
//{
//    key bd.BillingDocument,
//        bd.SoldToParty,
//        p.AddressID,
//        add.Street,
//        add.AddressID        as Address,
//        add.AddresseeFullName,
//        bp.IN_GSTIdentificationNumber,
//        p.Plant,
//        bd.BillingDocumentType,
//        add.OrganizationName1,
//        add.CityName,
//        add.DistrictName,
//        add.PostalCode,
//        add.StreetName,
//        add.StreetPrefixName1,
//        add.StreetPrefixName2,
//        add.StreetSuffixName1,
//        add.StreetSuffixName2,
//        add.Country,
//        add.Region,
//        add.HouseNumber,
//        add.AddressGroup
//     
//    
//}





