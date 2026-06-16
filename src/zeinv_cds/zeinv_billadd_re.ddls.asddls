@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'billing document customer address'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_BILLADD_RE as select from I_BillingDocumentPartner as bdp
//left outer join I_Plant as plt on plt.Plant = bdp.Customer
left outer join I_Address_2 as a1 on bdp.AddressID = a1.AddressID 
//or bdp.AddressID = a1.AddressID
{
    key a1.AddressID,
    key a1.AddressPersonID,
    key a1.AddressRepresentationCode,
    key bdp.BillingDocument,
    key bdp.PartnerFunction,
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
    bdp.Customer,
    bdp.Supplier,
    bdp.AddressID as addid,
    bdp.ContactPerson,
    bdp.ReferenceBusinessPartner
 
 
}
 
where  bdp.PartnerFunction = 'RE'  
 
 