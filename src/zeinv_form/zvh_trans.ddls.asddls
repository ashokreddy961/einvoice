@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'transportdetails value help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZVH_TRANS as select from I_Language
{
  key 'ROAD' as TransportMode,
      'By Road' as Description
}
where Language = 'E'
union all
select from I_Language
{
  key 'RAIL' as TransportMode ,
      'By Rail'as Description
}
where Language = 'E'
union all
select from I_Language
{
  key 'AIR' as TransportMode,
      'By Air' as Description
}
where Language = 'E'
union all
select from I_Language
{
  key 'SHIP' as TransportMode,
      'By Sea' as Description
}
where Language = 'E'
 
 