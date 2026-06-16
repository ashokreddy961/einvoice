@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'metadata for einv ui'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZEINV_ME_FM as select from 
ztb_uiheader
association [0..1] to ZFM_DETITEM as detitm on $projection.BillingDocument = detitm.Billingdoc 
association [0..1] to ZR_TBIRN_EINV as IRN on $projection.BillingDocument = IRN.Invno
association [0..1] to ZR_TBEWAYATTACH as _attach
on $projection.BillingDocument = _attach.Invno

 {
@EndUserText.label: 'Billing Document'
   key ztb_uiheader.billing_document as BillingDocument,
        
           @EndUserText.label: 'Invoice Date'
    ztb_uiheader.invoice_date as InvoiceDate,
   @EndUserText.label: 'Fiscal Year'
   ztb_uiheader.fiscalyear as FiscalYear,
   @EndUserText.label: 'Company Code Name'
    ztb_uiheader.company_code_name as CompanyCodeName,

    ztb_uiheader.plant as Plant,
        @EndUserText.label: 'Billing Document Type'
    
    ztb_uiheader.billingdocumenttype as Billingdocumenttype,

    ztb_uiheader.customer as Customer,
            @EndUserText.label: 'Customer Name'
    
    ztb_uiheader.customer_name as CustomerName,

        @EndUserText.label: 'PO Date'

    ztb_uiheader.po_date as PoDate,
//  case 
//  when ztb_uiheader.po_date = '00000000' then '19000101'
//  else ztb_uiheader.po_date
//end as PoDate,
            @EndUserText.label: 'PO Number'
    
    ztb_uiheader.po_number as PoNumber,
    
    ztb_uiheader.last_changed_at as LastChangedAt,
    
ztb_uiheader.referencecodeyear as originalreferencenumber ,
ztb_uiheader.companycode,
  

//    
////concat(
////   
//// '/sap/opu/odata4/sap/zce_form_einv_sb_api/srvd_a2x/sap/zce_form_einv_sd/0001/ZCE_FORM_EINV(''',
//// concat( billing_document,
//// ''')/form' )
////) as formURL,
////https://my433974-api.s4hana.cloud.sap/
///sap/opu/odata4/sap/zce_form_einv_sb_api/srvd_a2x/sap/zce_form_einv_sd/0001/ZCE_FORM_EINV



//        @EndUserText.label: 'Form URL'
//
//concat(
// '/sap/opu/odata4/sap/zce_form_einv_sb_api/srvd_a2x/sap/zce_form_einv_sd/0001/ZCE_FORM_EINV(billing_document=''',
// concat(
//   billing_document,
//   concat(
//     ''',invoice_date=''', 
//     concat(
//       invoice_date,
//       ''')/form'
//     )
//   )
// )
//) as formURL,
//'Print PDF' as form,

////////////////
concat(
//https://my434370-api.s4hana.cloud.sap
 '/sap/opu/odata4/sap/zce_form_einv_sb_api/srvd_a2x/sap/zce_form_einv_sd/0001/ZCE_FORM_EINV(''',
 concat( billing_document,
 ''')/form' )
) as formURL,
'Print PDF' as form,


@ObjectModel.text.element: ['BillingTypeText']
     @EndUserText.label: 'Billing Type'

ztb_uiheader.billingdocumenttype as BillingType,

case 
    when ztb_uiheader.billingdocumenttype = 'F2' then 'Invoice'
    when ztb_uiheader.billingdocumenttype = 'CBRE' then 'Credit Memo for Returns'
    when ztb_uiheader.billingdocumenttype = 'JSTO' then 'STO Billing'
    when ztb_uiheader.billingdocumenttype = 'DR' then 'Customer Invoice'
    when ztb_uiheader.billingdocumenttype = 'DG' then 'Customer Credit Memo'
     when ztb_uiheader.billingdocumenttype = 'MIGO 311' then 'Transfer Posting'
    when ztb_uiheader.billingdocumenttype = 'MIGO 201' then 'Consumption'
    when ztb_uiheader.billingdocumenttype = 'MIGO 541' then 'SubContracting'
 
    
    else ''
end as BillingTypeText,

ztb_uiheader.supplytype,
@EndUserText.label: 'Document Reference ID'
ztb_uiheader.documentreferenceid,

IRN.Irn,


case when IRN.Status is null then '01 (Yet To Post)'
 else ( case IRN.Status when '01' then ' 01 (Yet To Post)'
  when '02' then '02 (Success)' 
  when '03' then '03 (Failed)'
   when '04' then '04 (Yet To Cancel)' 
   when '05' then '05 (Cancelled Successfully)'
   when '06' then '06 (Invoice Reversed)' else '' end )
end as IRNStatusText,
@Consumption.valueHelpDefinition: [{  entity: { name: 'ZVHSTATUS', element: 'value_low' } }]
@ObjectModel.text.element: ['IRNStatusText']
@UI.textArrangement: #TEXT_LAST
IRN.Status as cboStatus,

//   @Consumption.valueHelpDefinition: [{  entity: { name: 'ZVHSTATUS', element: 'value_low' } }]
//IRN.Status as cboStatus,

@EndUserText.label: 'Transport ID'
IRN.Transportid as TransportID,
 
@EndUserText.label: 'Transport Mode'
@UI.identification: [{ position: 10 }]
IRN.Transportmode,
@EndUserText.label: 'Transport Code'
@UI.identification: [{ position: 20 }]
IRN.Transportcode,
 
@EndUserText.label: 'Transport Name'
@UI.identification: [{ position: 30 }]
IRN.Transportname,
@EndUserText.label: 'Docket Number'
@UI.identification: [{ position: 40 }]
IRN.Transportdocketnumber,
@EndUserText.label: 'Docket Date'
@UI.identification: [{ position: 50 }]
IRN.Transportdocketdate,
@EndUserText.label: 'Vehicle Number'
@UI.identification: [{ position: 60 }]
IRN.Vehiclenumber,
@EndUserText.label: 'Vehicle Type'
@UI.identification: [{ position: 70 }]
IRN.Vehicletype,
@EndUserText.label: 'Eway Bill Number'
@UI.identification: [{ position: 80 }]
IRN.Ewaybillnumber,
@EndUserText.label: 'Eway Bill Date'
@UI.identification: [{ position: 90 }]
IRN.Ewaybilldate,
case 
  when IRN.Ewaybillstatus is null then 'Initial'
  else
    case IRN.Ewaybillstatus
      when '' then 'Initial'
      when '01' then 'Yet to Generate'
      when '02' then 'Eway Generated'
      when '03' then 'Failed'
      else 'Unknown'
    end
end as EwayStatusText,
//@EndUserText.label: 'Eway Bill Status'
//@UI.identification: [{ position: 100 }]
@Consumption.valueHelpDefinition: [{ entity: { name: 'ZVH_EWAYSTATUS', element: 'EwayStatus' } }]
@ObjectModel.text.element: ['EwayStatusText']
@UI.textArrangement: #TEXT_LAST
IRN.Ewaybillstatus,
   @EndUserText.label: 'Long Text'

IRN.long_text,
cast( '' as abap.char(1) ) as NotesAction,
detitm,
_attach.MimeType,
_attach.FileName,

@EndUserText.label: 'EwayBill Attachment'
@Semantics.largeObject: {
    mimeType: 'MimeType',
    fileName: 'FileName'
}
_attach.EwaybillAttachment,
_attach
// 

}
where ( ztb_uiheader.billingdocumenttype = 'F2' 
or ztb_uiheader.billingdocumenttype = 'CBRE'
 or ztb_uiheader.billingdocumenttype = 'JSTO' 
 or ztb_uiheader.billingdocumenttype = 'DG'
 or ztb_uiheader.billingdocumenttype = 'DR'
 or     ztb_uiheader.billingdocumenttype = '311'  
  or  ztb_uiheader.billingdocumenttype = '201' 
  or   ztb_uiheader.billingdocumenttype = '541' 
 )

