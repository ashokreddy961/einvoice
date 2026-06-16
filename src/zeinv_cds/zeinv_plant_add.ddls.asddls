@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'plant address'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_PLANT_ADD as select from I_Plant as Plant
inner join I_Address_2 as Addr on Plant.AddressID = Addr.AddressID
inner join I_BusinessPlace as GSTIN on GSTIN.BusinessPlace = Plant.BusinessPlace
{
    key Plant.Plant,
    Plant.PlantName,
    Addr.CityName,
    Addr.Region,
    Addr.PostalCode,
    Addr.StreetName,
    Addr.StreetPrefixName1,
      Addr.OrganizationName1,
        
        Addr.DistrictName,
        Addr.StreetPrefixName2,
        Addr.StreetSuffixName1,
        Addr.StreetSuffixName2,
        Addr.Country,
    GSTIN.IN_GSTIdentificationNumber
}
