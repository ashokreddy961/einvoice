@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'form item details root'
@Metadata.ignorePropagatedAnnotations: true
define  view entity ZFM_DETITEM as select from ztb_uiitem as item
 
association to parent ZFM_DETHEAD as _header
on $projection.Billingdoc = _header.BillingDocument
// 
 
 
 
{
 
 
key item.billingdoc as Billingdoc,
key item.billing_document_item as BillingDocumentItem,
item.item_text as ItemText,
item.itemcode,
item.billing_quantity_unit as BillingQuantityUnit,
  @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
 
item.billing_quantity as BillingQuantity,
item.transaction_currency as TransactionCurrency,
@Semantics.amount.currencyCode: 'TransactionCurrency'
item.net_amount as NetAmount,
item.hsn_code as HsnCode,
@Semantics.amount.currencyCode: 'TransactionCurrency'
item.net_price_amount as NetPriceAmount,
@Semantics.amount.currencyCode: 'TransactionCurrency'
item.cgst_amount as CgstAmount,
@Semantics.amount.currencyCode: 'TransactionCurrency'
item.sgst_amount as SgstAmount,
@Semantics.amount.currencyCode: 'TransactionCurrency'
item.igst_amount as IgstAmount,
item.cgst_rate as CgstRate,
item.sgst_rate as SgstRate,
item.igst_rate as IgstRate,
item.cgst_unit as CgstUnit,
item.sgst_unit as SgstUnit,
item.igst_unit as IgstUnit,
item.uom as Uom,
item.tcsamount as Tcsamount,
item.taxcode as Taxcode,
item.glaccountname as Glaccountname,
item.invoicetotal as Invoicetotal,
item.annexure_batch,
item.annexure_desc,
item.annexure_hsn,
item.annexure_material,
item.annexurematerialdocumentitem,
  @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'

item.annexure_qty,
item.annexure_uom,
item.freightamount,
item.jeassignmentreference,
item.wbs_element_desc,
item.wbs_element_id,
item.wbs_element_name,
item.taxindicator,
_header
 
    
}
 
 