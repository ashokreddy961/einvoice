@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'billing document reference'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_BILL_REF as select from I_BillingDocumentItem as item
 
inner join I_BillingDocument as head
    on item.BillingDocument = head.BillingDocument
 
/* Return Delivery */
left outer join I_CustomerReturnDeliveryItem as retDel
    on retDel.CustomerReturnDelivery = item.ReferenceSDDocument
   and retDel.CustomerReturnDeliveryItem = item.ReferenceSDDocumentItem
 
/* Customer Return */
left outer join I_CustomerReturn as re
    on re.CustomerReturn = retDel.ReferenceSDDocument
 
/* Original Invoice (F2) */
left outer join I_BillingDocumentItem as f2
    on f2.BillingDocument = re.ReferenceSDDocument
    
    left outer join I_BillingDocument as f2head
    on f2.BillingDocument = f2head.BillingDocument
    
 
association [0..1] to I_Customer as _Customer
    on head.SoldToParty = _Customer.Customer
    
 
{
 
key item.BillingDocument,
key item.BillingDocumentItem,
 
head.BillingDocumentType,
head.BillingDocumentDate,
 
head.SoldToParty,
_Customer.CustomerName,
 
/* CBRE Reference Delivery */
item.ReferenceSDDocument as ReturnDelivery,
 
/* Customer Return */
re.CustomerReturn,
 
/* F2 Invoice */
f2.BillingDocument as OriginalInvoice,
 
/* F2 Referenced Delivery */
f2head.DocumentReferenceID as F2ReferencedDocument,
f2head.BillingDocumentDate as OriginalInvoiceDate
 
}
 
where head.BillingDocumentType = 'CBRE'
 
 