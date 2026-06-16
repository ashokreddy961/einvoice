*CLASS LHC_ZR_TBIRN_EINV DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
*  PRIVATE SECTION.
*    METHODS:
*      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
*        IMPORTING
*           REQUEST requested_authorizations FOR ZrTbirnEinv
*        RESULT result.
*ENDCLASS.
*
*CLASS LHC_ZR_TBIRN_EINV IMPLEMENTATION.
*  METHOD GET_GLOBAL_AUTHORIZATIONS.
*  ENDMETHOD.
*ENDCLASS.



CLASS LHC_ZR_TBIRN_EINV DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrTbirnEinv
        RESULT result.

*      validate_long_text FOR VALIDATE ON SAVE
*  IMPORTING entities FOR ZrTbirnEinv~validate_long_text.
ENDCLASS.




CLASS LHC_ZR_TBIRN_EINV IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.

*METHOD validate_long_text.
*
*  LOOP AT entities INTO DATA(ls_entity).
*
*    IF ls_entity- IS NOT INITIAL
*       AND strlen( ls_entity-long_text ) > 250.
*
*      APPEND VALUE #(
*        %tky = ls_entity-%tky
*        %msg = new_message(
*          id       = 'ZMSG'
*          number   = '001'
*          severity = if_abap_behv_message=>severity-error
*          v1       = 'Long text max 250 characters only'
*        )
*      ) TO reported-zrtbirneinv.
*
*    ENDIF.
*
*  ENDLOOP.
*
*ENDMETHOD.


ENDCLASS.
