@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'for form details'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZFM_DETHEAD as select from ztb_uiheader as head
 
 
  association [0..1] to ZR_TBIRN_EINV as _einvoice
 on head.billing_document = _einvoice.Invno
  
 composition [1..*] of ZFM_DETITEM as _item 
  association [0..*] to ZFM_ANNEXURE as _annexure
  on head.billing_document = _annexure.billingdoc
 
{
key  head.billing_document as BillingDocument,
  head.invoice_date as InvoiceDate,

  head.company_code_name as CompanyCodeName,
  head.company_gstin as CompanyGstin,
  head.plant as Plant,
  head.plant_name as PlantName,
  head.city_name as CityName,
  head.district_name as DistrictName,
  head.postal_code as PostalCode,
  head.street_name as StreetName,
  head.street_prefix1 as StreetPrefix1,
  head.street_prefix2 as StreetPrefix2,
  head.street_suffix1 as StreetSuffix1,
  head.customer as Customer,
  head.customer_name as CustomerName,
  head.customer_gstin as CustomerGstin,
  head.customer_street as CustomerStreet,
  head.customer_city as CustomerCity,
  head.customer_postal as CustomerPostal,
  head.payment_terms as PaymentTerms,
  head.place_of_supply as PlaceOfSupply,
  head.po_date as PoDate,
  head.po_number as PoNumber,
  head.transaction_currency as TransactionCurrency,
  head.last_changed_at as LastChangedAt,
  head.billto_name as BilltoName,
  head.billto_street as BilltoStreet,
  head.billto_house_no as BilltoHouseNo,
  head.billto_city as BilltoCity,
  head.billto_district as BilltoDistrict,
  head.billto_region as BilltoRegion,
  head.billto_postal_code as BilltoPostalCode,
  head.billto_country as BilltoCountry,
  head.billto_street1 as BilltoStreet1,
  head.billto_street2 as BilltoStreet2,
  head.billto_street3 as BilltoStreet3,
  head.billto_street4 as BilltoStreet4,
  head.billto_gstin as billto_gstin,
  head.shipto_customer as ShiptoCustomer,
  head.shipto_name as ShiptoName,
  head.shipto_street as ShiptoStreet,
  head.shipto_house_no as ShiptoHouseNo,
  head.shipto_city as ShiptoCity,
  head.shipto_district as ShiptoDistrict,
  head.shipto_region as ShiptoRegion,
  head.shipto_postal_code as ShiptoPostalCode,
  head.shipto_country as ShiptoCountry,
  head.shipto_street1 as ShiptoStreet1,
  head.shipto_street2 as ShiptoStreet2,
  head.shipto_street3 as ShiptoStreet3,
  head.shipto_street4 as ShiptoStreet4,
  head.soldto_customer ,
  head.soldto_city,
  head.soldto_country,
  head.soldto_district,
  head.soldto_house_no,
  head.soldto_name,
  head.soldto_postal_code,
  head.soldto_region,
  head.soldto_street,
  head.soldto_street1,
  head.soldto_street2,
  head.soldto_street3,
  head.soldto_street4,
  
  head.billingdocumenttype as Billingdocumenttype,
  head.lastchangedatetime as Lastchangedatetime,
  head.documentreferenceid as Documentreferenceid,
  head.supplytype as Supplytype,
  head.docrefidf2 as Docrefidf2,
  head.orginalinvoicedate as originalinvoicedate,
  head.remarks as Remarks,
  head.companycode as Companycode,
  head.fiscalyear as Fiscalyear,
  head.paymentduedate as Paymentduedate,
  head.customergroup as Customergroup,
  head.customergrouptext as Customergrouptext,
  head.housebank,
  head.bank_account,
  head.bank_name,
  head.neft_ifsc_rtgs_code,
  head.yy1_customeraddresspo_pdh,
  head.yy1_customernamepo_pdh,
  head.supplying_plant,
  head.invoicereversal,
  head.lutnumber,
  head.referencecodeyear,
  head.wbs_element_desc,
  head.wbs_element_id,
  head.wbs_element_name,
  _item,
  _einvoice,
  _annexure
}
 
 
 
where ( head.billingdocumenttype = 'F2'
     or head.billingdocumenttype = 'CBRE'
     or head.billingdocumenttype = 'JSTO'
     or head.billingdocumenttype = 'DG'
     or head.billingdocumenttype = 'DR'
     or head.billingdocumenttype = '201'
     or head.billingdocumenttype = '311'
     or head.billingdocumenttype = '541' 
     )
 
 