@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'value help supplytype'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZVH_SUPTYPE as select distinct from I_Country
{
    key cast('B2B' as abap.char(3)) as SupplyType,
    cast('Business to Business' as abap.char(30)) as SupplyTypeText
}
 
union all
 
select distinct from I_Country
{
    key cast('B2C' as abap.char(3))as SupplyType,
    cast('Business to Consumer' as abap.char(30)) as SupplyTypeText
}

 union all
 
 select distinct from I_Country
{
    key cast('MIG' as abap.char(3))as SupplyType,
    cast('Goods Movement' as abap.char(30)) as SupplyTypeText
}

 
 union all
 
 select distinct from I_Country
{
    key cast('EXP' as abap.char(3))as SupplyType,
    cast('EXPORTING' as abap.char(30)) as SupplyTypeText
}
