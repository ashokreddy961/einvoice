@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'billing doc address for AG sp'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_BILLADD_AG as select from  I_PurchaseOrderAPI01 as po 
left outer join I_Plant as plt 
    on plt.Plant = po.SupplyingPlant 
left outer join I_Address_2 as a1  
    on plt.AddressID = a1.AddressID 
 left outer join I_BusinessPlace as bp
    on bp.BusinessPlace = po.SupplyingPlant
    
    left outer join I_OutboundDeliveryItem as OBD 
    on OBD.PurchaseOrder = po.PurchaseOrder 
    
    left outer join I_BillingDocumentItem as BITEM
     on BITEM.ReferenceSDDocument  =  OBD.OutboundDelivery


{
    key a1.AddressID,
    key a1.AddressPersonID,
    key a1.AddressRepresentationCode,
    
    
    key po.PurchaseOrder as BillingDocument,   
    'AG' as PartnerFunction,                   
BITEM.BillingDocument as BILLDOC,
    a1.AddresseeFullName,
    a1.PersonGivenName,
    a1.PersonFamilyName,
    a1.OrganizationName1,
    a1.CityNumber,
    
    a1.DistrictName,
    a1.CompanyPostalCode,
    a1.Street,
    
    a1.StreetPrefixName1,
    a1.StreetPrefixName2,
    a1.StreetSuffixName1,
    a1.StreetSuffixName2,
    a1.Country,
    a1.Region,
    a1.FormOfAddress,
    a1.HouseNumber,
    a1.StreetName,
    a1.PostalCode,
    a1.CityName,
    a1.AddressTimeZone,
    a1.AddressGroup,
    a1.DistrictNumber,
    a1.Village,

    '' as Customer,
    '' as Supplier,
    a1.AddressID as addid,
    '' as ContactPerson,
    '' as ReferenceBusinessPartner,

    bp.IN_GSTIdentificationNumber as TaxNumber3
}

where po.PurchaseOrderType = 'UB'

//
// I_BillingDocumentPartner as bdp
//left outer join I_Plant as plt on plt.Plant = bdp.Customer
//left outer join I_Address_2 as a1 on plt.AddressID = a1.AddressID
//
//left outer join I_BusinessPlace as c1 on 
//bdp.Customer = c1.BusinessPlace

//{
//    key a1.AddressID,
//    key a1.AddressPersonID,
//    key a1.AddressRepresentationCode,
//    
//    key bdp.BillingDocument,
//    key bdp.PartnerFunction,
//    a1.AddresseeFullName,
//    a1.PersonGivenName,
//    a1.PersonFamilyName,
//    a1.OrganizationName1,
//    a1.CityNumber,
//    
//    a1.DistrictName,
//  
//    a1.CompanyPostalCode,
//    a1.Street,
//    
//    a1.StreetPrefixName1,
//    a1.StreetPrefixName2,
//    a1.StreetSuffixName1,
//    a1.StreetSuffixName2,
//    a1.Country,
//    a1.Region,
//    a1.FormOfAddress,
//    a1.HouseNumber,
//    a1.StreetName,
//      a1.PostalCode,
//   a1.CityName,
//   a1.AddressTimeZone,
//    a1.AddressGroup,
//    a1.DistrictNumber,
//    a1.Village,
//    bdp.Customer,
//    bdp.Supplier,
//    bdp.AddressID as addid,
//    bdp.ContactPerson,
//    bdp.ReferenceBusinessPartner,
//    c1.IN_GSTIdentificationNumber as TaxNumber3
// 
// 
//}
// 
// where  bdp.PartnerFunction = 'AG'  
// 
