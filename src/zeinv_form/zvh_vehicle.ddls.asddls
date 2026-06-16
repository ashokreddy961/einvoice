@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'vehicle details value help'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZVH_VEHICLE as select from 
I_Language
{
  key 'R' as VehicleType,
      'Regular' as Description
}
where Language = 'E'
union all
select from I_Language
{
  key 'O' as VehicleType,
      'ODC' as Description
}
where Language = 'E'
 
 