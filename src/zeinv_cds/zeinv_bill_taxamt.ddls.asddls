@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'billing document tax amount'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_BILL_TAXAMT as select from I_BillingDocItemPrcgElmntBasic as bill1
{
    key bill1.BillingDocument,
    key bill1.BillingDocumentItem,
    bill1.TransactionCurrency,
 
 
 
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum(case  when bill1.ConditionType = 'ZPR0' then bill1.ConditionRateValue  else 0 end ) as ZPRO_Rate,
 
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum(case when bill1.ConditionType = 'JOIG'then bill1.ConditionAmount else cast( 0 as abap.curr( 15, 2 ) )end ) as JOIG_Amount,
 
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum(case when bill1.ConditionType = 'JOSG' then bill1.ConditionAmount else cast( 0 as abap.curr( 15, 2 ) )end ) as JOSG_Amount,
 
    @Semantics.amount.currencyCode: 'TransactionCurrency'
    sum(case when bill1.ConditionType = 'JOCG' then bill1.ConditionAmount else cast( 0 as abap.curr( 15, 2 ) ) end ) as JOCG_Amount,
    
    @Semantics.amount.currencyCode: 'TransactionCurrency'
sum(
    case 
        when bill1.ConditionType = 'ZFRT' 
        then bill1.ConditionAmount 
        else cast( 0 as abap.curr( 15, 2 ) )
    end
) as Freight_Amount,
    
 
max(case when bill1.ConditionType = 'JOIG'  
         then cast( bill1.ConditionRateRatio as abap.dec( 5, 2 ) )
         else cast( 0 as abap.dec( 5, 2 ) )
end
) as igst_rate,
 
max( case when bill1.ConditionType = 'JOSG' 
          then cast( bill1.ConditionRateRatio as abap.dec( 5, 2 ) ) 
          else cast( 0 as abap.dec( 5, 2 ) )
    end
) as sgst_rate,
 
max(case when bill1.ConditionType = 'JOCG' 
         then cast( bill1.ConditionRateRatio as abap.dec( 5, 2 ) ) 
         else cast( 0 as abap.dec( 5, 2 ) )
    end
) as Cgst_rate,
 
    /* ZPRO Percentage Unit */
max(case when bill1.ConditionType = 'JOIG' 
then bill1.ConditionRateRatioUnit 
 else '' end
    ) as IGSTPER,
    
max(case when bill1.ConditionType = 'JOSG' then bill1.ConditionRateRatioUnit else '' end
) as SGSTPER,
 
max(case when bill1.ConditionType = 'JOCG' then bill1.ConditionRateRatioUnit else '' end
    ) as CGSTPER
}
group by
    bill1.BillingDocument,
    bill1.BillingDocumentItem,
    bill1.TransactionCurrency
 
 
 