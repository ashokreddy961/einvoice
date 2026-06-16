@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'VALUE HELP FOR BILLINGTYP'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZVH_BILLTYP as select distinct from I_BillingDocumentTypeText as b1
{
    key BillingDocumentType as BillingDocumentType,
    BillingDocumentTypeName as BillingTypeDescription
}
where (b1.BillingDocumentType = 'F2'
or b1.BillingDocumentType = 'CBRE'
or b1.BillingDocumentType = 'JSTO')  
 
union all
 
select  distinct  from I_AccountingDocumentTypeText as item
{
    key AccountingDocumentType as BillingDocumentType,
    AccountingDocumentTypeName as BillingTypeDescription
}
where
(
      ( item.AccountingDocumentType = 'DR')
 
   or ( item.AccountingDocumentType = 'DG')  )
   
   union all
   
   select  distinct  from I_MaterialDocumentItem_2 as mat
   
   {
   key GoodsMovementType as BillingDocumentType,

    case mat.GoodsMovementType
        when '311' then 'TRANSFER POSTING'
        when '541' then 'SUBCONTRACTING'
        when '201' then 'CONSUMPTION'
        else 'MATERIAL MOVEMENT'
    end as BillingTypeDescription
 
}


 where (
    ( mat.GoodsMovementType ='311' )
 or ( mat.GoodsMovementType ='541' )
 or ( mat.GoodsMovementType ='201' )
  )
