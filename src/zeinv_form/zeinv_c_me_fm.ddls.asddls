@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection view rap app'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define root view entity ZEINV_C_ME_FM
provider contract transactional_query
as projection on ZEINV_ME_FM
association [1..1] to ZEINV_ME_FM as _BaseEntity
  on $projection.BillingDocument = _BaseEntity.BillingDocument
//   and $projection.FiscalYear      = _BaseEntity.FiscalYear
  
  association [0..*] to ztb_ewayattach as _attach
on $projection.BillingDocument = _attach.invno

  {
  @UI.lineItem: [
    { type: #FOR_ACTION, dataAction: 'cancel04', label: 'Cancel Invoice', position: 2 }
  ]

  key BillingDocument,
      @EndUserText.label: 'Invoice Date'
  
     InvoiceDate,
  
 FiscalYear,
   @EndUserText.label: 'Company Code Name'
  CompanyCodeName,
  Plant,
     @EndUserText.label: 'Billing Document Type'
  
  Billingdocumenttype,
  Customer,
     @EndUserText.label: 'Customer Name'
  
  CustomerName,
   
         @EndUserText.label: 'PO Date'
  
  PoDate,
     @EndUserText.label: 'PO Number'
  PoNumber,
     @EndUserText.label: 'Last Changed At'
  LastChangedAt,
  
  formURL,
  form,
     @EndUserText.label: 'Billing Type'
  BillingType,
  BillingTypeText,
  supplytype,
       @EndUserText.label: 'Document Reference ID'
  
  documentreferenceid,
  cboStatus,
  TransportID,
  Transportmode,
  Transportcode,
  Transportname,
  Transportdocketnumber,
  Transportdocketdate,
  Vehiclenumber,
  Vehicletype,
  Ewaybillnumber,
  Ewaybilldate,
  Ewaybillstatus,
   @EndUserText.label: 'Long Text'
  long_text,
  detitm,
  _attach
}








//@AbapCatalog.viewEnhancementCategory: [#NONE]
//@AccessControl.authorizationCheck: #NOT_REQUIRED
//@EndUserText.label: 'projection view rap app'
//@Metadata.ignorePropagatedAnnotations: true
//define root view entity ZEINV_C_ME_FM
//provider contract transactional_query
// as projection on  ZEINV_ME_FM
// association [1..1] to ZEINV_ME_FM as _BaseEntity
//  on $projection.BillingDocument = _BaseEntity.BillingDocument
//{
//
//@UI.lineItem: [
////  { type: #FOR_ACTION, dataAction: 'sync', label: 'Sync', position: 1 },
//  { type: #FOR_ACTION, dataAction: 'cancel04', label: 'Cancel Invoice', position: 2 }
//]
// 
//    key BillingDocument,
//    CompanyCodeName,
//    Plant,
//    Billingdocumenttype,
//    Customer,
//    CustomerName,
//    InvoiceDate,
//    PoDate,
//    PoNumber,
//    LastChangedAt,
//    formURL,
//    form,
//    BillingType,
//    BillingTypeText,
//    supplytype,
//    documentreferenceid,
//    @Consumption.valueHelpDefinition: [
//    {
//    entity : { name: 'ZVHSTATUS' , element: 'Status'  }
//    }
//    ]
//    cboStatus,
//    TransportID,
//    Transportmode,
//    Transportcode,
//    Transportname,
//    Transportdocketnumber,
//    Transportdocketdate,
//    Vehiclenumber,
//    Vehicletype,
//    Ewaybillnumber,
//    Ewaybilldate,
//    Ewaybillstatus,
//    /* Associations */
//    detitm
//}
