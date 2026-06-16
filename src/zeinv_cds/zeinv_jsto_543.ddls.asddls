@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'for document type 543 annexure data'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_JSTO_543 as select from I_MaterialDocumentItem_2 as mitem

      
      left outer join I_PurchaseOrderAPI01 as pohead
    on mitem.MaterialDocument = pohead.YY1_Annexure_MaterialD_PDH
      and pohead.PurchaseOrderType = 'UD'
left  outer join I_ProductPlantBasic as pp
on pp.Plant = mitem.Plant
and pp.Product = mitem.Material
left outer join I_Product as prod
on prod.Product = mitem.Material
 
 


{
    key mitem.MaterialDocument,
    key mitem.MaterialDocumentYear,
    key mitem.MaterialDocumentItem,
    mitem.Material  as Material,
  //  mitem.MaterialDocumentItemText   as MaterialDescription,
  prod.YY1_ItemLong_Text_PRD as MaterialDescription,
    mitem.EntryUnit,
   
    @Semantics.quantity.unitOfMeasure: 'EntryUnit'
    mitem.QuantityInEntryUnit      as Quantity,
    mitem.EntryUnit      as UOM,
   mitem.YY1_HSNCode_MMI   as HSNCode,
    mitem.Batch     as Batch,

    mitem.GoodsMovementType,
    pp.ConsumptionTaxCtrlCode,
    pp.Plant,
    mitem.PurchaseOrder as po,
    mitem.PurchaseOrderItem as poitem,
    pohead.YY1_Annexure_MaterialD_PDH
    
}
where
   mitem.GoodsMovementType = '543'    

