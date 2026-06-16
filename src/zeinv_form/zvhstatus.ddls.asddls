@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'status field'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.usageType: {
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@ObjectModel.dataCategory: #VALUE_HELP

define view entity ZVHSTATUS as select from  DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDEINV_STATUSUI' )
{
    key domain_name,
    key value_position,
    key language,
    
        value_low  as Status,
        @Semantics.text: true
        text       as StatusText

//    key value_low as Status,
//
//    @Semantics.text: true
//    text as StatusText
}
 where language = 'E'
 
 