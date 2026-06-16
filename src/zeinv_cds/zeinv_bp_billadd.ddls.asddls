@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'combined billingdocument were address'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_BP_BILLADD as select from ZEINV_BILLADD_RE   as re
    left outer join ZEINV_BILLADD_WE as we
      on we.BillingDocument = re.BillingDocument
{
    
    key re.BillingDocument,
 
    /* ---------------------- */
    /* Bill-To (RE) Fields    */
    /* ---------------------- */
    re.Customer                           as BillToCustomer,
  //  re.OrganizationName1                  as BillToName,
  re.AddresseeFullName as BillToName,
    re.StreetName                         as BillToStreet,
    re.HouseNumber                        as BillToHouseNo,
    re.CityName                           as BillToCity,
    re.DistrictName                       as BillToDistrict,
    re.Region                             as BillToRegion,
    re.PostalCode                         as BillToPostalCode,
    re.Country                            as BillToCountry,
    re.StreetPrefixName1                  as BILLTOSTREET1,
    re.StreetPrefixName2                  as BILLTOSTREET2,
    re.StreetSuffixName1                  as BILLTOSTREET3,
    re.StreetSuffixName2                 as BILLTOSTREET4,
 
    /* ---------------------- */
    /* Ship-To (WE) Fields    */
    /* ---------------------- */
    we.Customer                           as ShipToCustomer,
  //  we.OrganizationName1                  as ShipToName,
  we.AddresseeFullName                   as ShipToName,
    we.StreetName                         as ShipToStreet,
    we.HouseNumber                        as ShipToHouseNo,
    we.CityName                           as ShipToCity,
    we.DistrictName                       as ShipToDistrict,
    we.Region                             as ShipToRegion,
    we.PostalCode                         as ShipToPostalCode,
    we.Country                            as ShipToCountry,
    we.StreetPrefixName1                  as SHIPTOSTREET1,
    we.StreetPrefixName2                  as SHIPTOSTREET2,
    we.StreetSuffixName1                  as SHIPTOSTREET3,
    we.StreetSuffixName2                  as SHIPTOSTREET4
}
 
 