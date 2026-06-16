@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'For Supplier data in Migo'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_MIGO_RE as select from  I_Supplier as sup 
left outer join I_Address_2 as a1 on sup.AddressID = a1.AddressID 
//left outer join I_StorageLocationAddress as sg on sg.Plant = m.Plant 
//and sg.StorageLocation = m.StorageLocation
//left outer join I_Address_2 as a2 on a2.AddressID = sg.AddressID
//left outer join I_BusinessPlace as bp 
//on bp.BusinessPlace = plt.Plant
left outer join I_Businesspartnertaxnumber as gst
on gst.BusinessPartner = sup.Supplier
and gst.BPTaxType = 'IN3'

{
     key a1.AddressID,
    key a1.AddressPersonID,
    key a1.AddressRepresentationCode,
   // key bdp.BillingDocument,
   // key bdp.PartnerFunction,
    a1.AddressObjectType,
    a1.CorrespondenceLanguage,
    a1.PrfrdCommMediumType,
    a1.AddresseeFullName,
    a1.PersonGivenName,
    a1.PersonFamilyName,
    a1.OrganizationName1,
    a1.OrganizationName2,
    a1.OrganizationName3,
    a1.OrganizationName4,
    a1.AddressSearchTerm1,
    a1.AddressSearchTerm2,
    a1.CityNumber,
    a1.CityName,
    a1.DistrictName,
    a1.VillageName,
    a1.PostalCode,
    a1.CompanyPostalCode,
    a1.Street,
    a1.StreetName,
    a1.StreetAddrNonDeliverableReason,
    a1.StreetPrefixName1,
    a1.StreetPrefixName2,
    a1.StreetSuffixName1,
    a1.StreetSuffixName2,
    a1.HouseNumber,
    a1.HouseNumberSupplementText,
    a1.Building,
    a1.Floor,
    a1.RoomNumber,
    a1.Country,
    a1.Region,
    a1.FormOfAddress,
 
    
    a1.POBoxPostalCode,
    
 
    a1.AddressGroup,
    a1.DistrictNumber,
    a1.Village,
    //bdp.Customer,
    sup.Supplier,
    sup.AddressID as addid,
    gst.BPTaxNumber as TaxNumber3
    //bdp.ContactPerson,
   // bdp.ReferenceBusinessPartner,
   // bp.IN_GSTIdentificationNumber
 
 
}
