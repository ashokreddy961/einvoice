@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'payment term days'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZEINV_BILLPAY_DAYS as select from I_PaymentTermsText
{
    key PaymentTerms,
 
    cast(
        case PaymentTerms
 
            when 'NT00' then 0
            when 'NT08' then 8
            when 'NT15' then 15
            when 'NT30' then 30
            when 'NT45' then 45
            when 'NT60' then 60
 
            else 30
 
        end as abap.int4
    ) as FinalDays
 
}
 
 
 