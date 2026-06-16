CLASS lhc_ewayenv DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ewayenv RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ewayenv RESULT result.

    METHODS cancel04 FOR MODIFY
      IMPORTING keys FOR ACTION ewayenv~cancel04 RESULT result.

    METHODS generateeway FOR MODIFY
      IMPORTING keys FOR ACTION ewayenv~generateeway RESULT result.

    METHODS transdetails FOR MODIFY
      IMPORTING keys FOR ACTION ewayenv~transdetails RESULT result.
      METHODS LongText FOR MODIFY
  IMPORTING keys FOR ACTION ewayenv~LongText RESULT result.

*METHODS sync FOR MODIFY
*  IMPORTING keys FOR ACTION ewayenv~sync .



ENDCLASS.



CLASS lhc_ewayenv IMPLEMENTATION.

METHOD get_global_authorizations.
ENDMETHOD.



METHOD get_instance_features.

  READ ENTITIES OF ZEINV_ME_FM
    IN LOCAL MODE
    ENTITY Ewayenv
    FIELDS ( BillingDocument cboStatus supplytype BillingType )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

  LOOP AT lt_data INTO DATA(ls_data).

    DATA(lv_cancel)    = if_abap_behv=>fc-o-disabled.
    DATA(lv_transport) = if_abap_behv=>fc-o-disabled.
    DATA(lv_eway)      = if_abap_behv=>fc-o-disabled.
 DATA(lv_sync)      = if_abap_behv=>fc-o-enabled.
    DATA(lv_supply) = to_upper( condense( ls_data-supplytype ) ).
    DATA(lv_status) = condense( ls_data-cboStatus ).
    DATA(lv_btype)  = condense( ls_data-BillingType ).

    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.



    SELECT SINGLE   *
      FROM ztb_irn_einv
      WHERE invno = @lv_invno
      INTO @DATA(ls_check).

          DATA(lv_transport_filled) = abap_false.

IF ls_check-transportmode IS NOT INITIAL
 OR ls_check-vehiclenumber IS NOT INITIAL
 OR ls_check-transportcode IS NOT INITIAL
 OR ls_check-transportname IS NOT INITIAL
 OR ls_check-transportid IS NOT INITIAL
 OR ls_check-transportdocketnumber IS NOT INITIAL
 OR ls_check-transportdocketdate IS NOT INITIAL.

  lv_transport_filled = abap_true.

  ENDIF.

    " MIGO Documents
    IF lv_btype = '201' OR lv_btype = '311' OR lv_btype = '541'.

      lv_cancel = if_abap_behv=>fc-o-disabled.
      lv_transport = if_abap_behv=>fc-o-enabled.

*      IF ls_check-transportid IS NOT INITIAL
*         AND ls_check-ewaybillstatus IS INITIAL.
**            OR ls_check-ewaybillstatus = '03' ).
*        lv_eway = if_abap_behv=>fc-o-enabled.
*      ENDIF.

IF lv_transport_filled = abap_true
   AND ls_check-ewaybillstatus IS INITIAL.

  lv_eway = if_abap_behv=>fc-o-enabled.

ENDIF.



      IF lv_status = '06'.  " Reversed
  lv_cancel    = if_abap_behv=>fc-o-disabled.
  lv_transport = if_abap_behv=>fc-o-disabled.
  lv_eway      = if_abap_behv=>fc-o-disabled.
  endif.

    ELSE.

*      IF lv_supply = 'B2B' AND lv_status = '02'.
      IF lv_supply = 'B2B' AND ( lv_status = '02' OR lv_status = '03' ).
        lv_cancel    = if_abap_behv=>fc-o-enabled.
        lv_transport = if_abap_behv=>fc-o-enabled.
      ENDIF.

      IF lv_supply = 'B2C'.
        lv_cancel    = if_abap_behv=>fc-o-enabled.
        lv_transport = if_abap_behv=>fc-o-enabled.
      ENDIF.

*      IF ls_check-transportid IS NOT INITIAL
*         AND ls_check-ewaybillstatus IS INITIAL.
*        lv_eway = if_abap_behv=>fc-o-enabled.
*      ENDIF.

 IF lv_transport_filled = abap_true
         AND ls_check-ewaybillstatus IS INITIAL.

        lv_eway = if_abap_behv=>fc-o-enabled.

      ENDIF.


    " 🚫 Disable Transport for DG & DR (FINAL OVERRIDE)
    IF lv_btype = 'DG' OR lv_btype = 'DR'.
      lv_transport = if_abap_behv=>fc-o-disabled.
    ENDIF.

    ENDIF.

IF ls_check-ewaybillstatus = '03'.

  CASE lv_btype.
    WHEN '201' OR '311' OR '541'
       OR 'F2'  OR 'DR'  OR 'DG'
       OR 'CBRE' OR 'JSTO'.

      lv_eway = if_abap_behv=>fc-o-enabled.

  ENDCASE.

ENDIF.



    APPEND VALUE #(
      %tky = ls_data-%tky
      %action-cancel04     = lv_cancel
      %action-Transdetails = lv_transport
      %action-GenerateEway = lv_eway
*        %action-sync      = lv_sync
    ) TO result.

  ENDLOOP.

ENDMETHOD.

METHOD cancel04.

  DATA: lt_update TYPE TABLE FOR UPDATE ZR_TBIRN_EINV,
        lt_read   TYPE TABLE FOR READ RESULT ZEINV_ME_FM.

  " Read selected rows
  READ ENTITIES OF ZEINV_ME_FM
    IN LOCAL MODE
    ENTITY Ewayenv
    FIELDS ( BillingDocument )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

  LOOP AT lt_data INTO DATA(ls_data).

    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.

    APPEND VALUE #(
      %key-Invno = lv_invno
      %control-status = if_abap_behv=>mk-on
      status = '04'
    ) TO lt_update.

  ENDLOOP.

  " Update DB
  MODIFY ENTITIES OF ZR_TBIRN_EINV
    ENTITY ZrTbirnEinv
    UPDATE FIELDS ( status )
    WITH lt_update.

  " Read again to refresh UI
  READ ENTITIES OF ZEINV_ME_FM
    IN LOCAL MODE
    ENTITY Ewayenv
    ALL FIELDS
    WITH CORRESPONDING #( keys )
    RESULT lt_read.

  result = VALUE #( FOR row IN lt_read ( %tky = row-%tky ) ).

ENDMETHOD.

*METHOD cancel04.
*
*  READ ENTITIES OF ZEINV_ME_FM
*    IN LOCAL MODE
*    ENTITY Ewayenv
*    FIELDS ( BillingDocument )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_data).
*
*  DATA lt_update TYPE TABLE FOR UPDATE ZR_TBIRN_EINV.
*
*  LOOP AT lt_data INTO DATA(ls_data).
*
*    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.
*
*    APPEND VALUE #(
*      %key-Invno = lv_invno
*      %control-status = if_abap_behv=>mk-on
*      status = '04'
*    ) TO lt_update.
*
*  ENDLOOP.
*
*  MODIFY ENTITIES OF ZR_TBIRN_EINV
*    ENTITY ZrTbirnEinv
*    UPDATE FIELDS ( status )
*    WITH lt_update.
*
*  result = VALUE #( FOR row IN lt_data ( %tky = row-%tky ) ).
*
*ENDMETHOD.



METHOD GenerateEway.

  DATA lt_update TYPE TABLE FOR UPDATE ZR_TBIRN_EINV.

  READ ENTITIES OF ZEINV_ME_FM
    IN LOCAL MODE
    ENTITY Ewayenv
    FIELDS ( BillingDocument )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

  LOOP AT lt_data INTO DATA(ls_data).

    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.

    APPEND VALUE #(
      %key-Invno = lv_invno
      %control-ewaybillstatus = if_abap_behv=>mk-on
      ewaybillstatus = '01'
    ) TO lt_update.

  ENDLOOP.

  MODIFY ENTITIES OF ZR_TBIRN_EINV
    ENTITY ZrTbirnEinv
    UPDATE FIELDS ( ewaybillstatus )
    WITH lt_update.

  result = VALUE #( FOR row IN lt_data ( %tky = row-%tky ) ).

ENDMETHOD.



METHOD Transdetails.

  DATA: lt_update   TYPE TABLE FOR UPDATE zr_tbirn_einv,
        lt_create   TYPE TABLE FOR CREATE zr_tbirn_einv,
        ls_existing TYPE ztb_irn_einv.

  READ ENTITIES OF ZEINV_ME_FM
    IN LOCAL MODE
    ENTITY Ewayenv
    FIELDS ( BillingDocument )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

  LOOP AT lt_data INTO DATA(ls_data).

    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.

    IF lv_invno IS INITIAL.
      CONTINUE.
    ENDIF.

    SELECT SINGLE *
      FROM ztb_irn_einv
      WHERE invno = @lv_invno
      INTO @ls_existing.

    READ TABLE keys INTO DATA(ls_key)
      WITH KEY %tky = ls_data-%tky.

    DATA(ls_param) = ls_key-%param.

    " Prefill (but allow save in same call)
    IF ls_existing IS NOT INITIAL AND
       ls_param-TransportMode IS INITIAL AND
       ls_param-VehicleNumber IS INITIAL AND
       ls_param-TransportCode IS INITIAL.

      result = VALUE #( BASE result (
        %tky = ls_data-%tky
        %param-TransportMode         = ls_existing-transportmode
        %param-VehicleType           = ls_existing-vehicletype
        %param-VehicleNumber         = ls_existing-vehiclenumber
        %param-TransportCode         = ls_existing-transportcode
        %param-TransportName         = ls_existing-transportname
        %param-TransportId           = ls_existing-transportid
        %param-TransportDocketNumber = ls_existing-transportdocketnumber
        %param-TransportDocketDate   = ls_existing-transportdocketdate
      ) ).
    ENDIF.

    IF ls_existing IS INITIAL.

      " CREATE
      APPEND VALUE #(
        %cid = |CID_{ lv_invno }|
        %key-Invno = lv_invno

        %control-Invno                 = if_abap_behv=>mk-on
        %control-Ackno                 = if_abap_behv=>mk-on
        %control-transportmode         = if_abap_behv=>mk-on
        %control-vehicletype           = if_abap_behv=>mk-on
        %control-vehiclenumber         = if_abap_behv=>mk-on
        %control-transportcode         = if_abap_behv=>mk-on
        %control-transportname         = if_abap_behv=>mk-on
        %control-transportid           = if_abap_behv=>mk-on
        %control-transportdocketnumber = if_abap_behv=>mk-on
        %control-transportdocketdate   = if_abap_behv=>mk-on

        Invno = lv_invno
        Ackno = lv_invno

        transportmode          = ls_param-TransportMode
        vehicletype            = ls_param-VehicleType
        vehiclenumber          = ls_param-VehicleNumber
        transportcode          = ls_param-TransportCode
        transportname          = ls_param-TransportName
        transportid            = ls_param-TransportId
        transportdocketnumber  = ls_param-TransportDocketNumber
        transportdocketdate    = ls_param-TransportDocketDate
      ) TO lt_create.

    ELSE.

      " UPDATE
      APPEND VALUE #(
        %key-Invno = lv_invno

        %control-transportmode         = if_abap_behv=>mk-on
        %control-vehicletype           = if_abap_behv=>mk-on
        %control-vehiclenumber         = if_abap_behv=>mk-on
        %control-transportcode         = if_abap_behv=>mk-on
        %control-transportname         = if_abap_behv=>mk-on
        %control-transportid           = if_abap_behv=>mk-on
        %control-transportdocketnumber = if_abap_behv=>mk-on
        %control-transportdocketdate   = if_abap_behv=>mk-on

        transportmode          = ls_param-TransportMode
        vehicletype            = ls_param-VehicleType
        vehiclenumber          = ls_param-VehicleNumber
        transportcode          = ls_param-TransportCode
        transportname          = ls_param-TransportName
        transportid            = ls_param-TransportId
        transportdocketnumber  = ls_param-TransportDocketNumber
        transportdocketdate    = ls_param-TransportDocketDate
      ) TO lt_update.

    ENDIF.

  ENDLOOP.

  IF lt_create IS NOT INITIAL.
    MODIFY ENTITIES OF zr_tbirn_einv
      ENTITY ZrTbirnEinv
      CREATE FROM lt_create.
  ENDIF.

  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zr_tbirn_einv
      ENTITY ZrTbirnEinv
      UPDATE FIELDS (
        transportmode
        vehicletype
        vehiclenumber
        transportcode
        transportname
        transportid
        transportdocketnumber
        transportdocketdate
      )
      WITH lt_update.
  ENDIF.

  result = VALUE #( FOR row IN lt_data ( %tky = row-%tky ) ).

ENDMETHOD.

METHOD LongText.

  DATA: lt_update   TYPE TABLE FOR UPDATE zr_tbirn_einv,
        lt_create   TYPE TABLE FOR CREATE zr_tbirn_einv,
        ls_existing TYPE ztb_irn_einv.

  READ ENTITIES OF ZEINV_ME_FM
    IN LOCAL MODE
    ENTITY Ewayenv
    FIELDS ( BillingDocument )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_data).

  LOOP AT lt_data INTO DATA(ls_data).

    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.

    IF lv_invno IS INITIAL.
      CONTINUE.
    ENDIF.

    SELECT SINGLE *
      FROM ztb_irn_einv
      WHERE invno = @lv_invno
      INTO @ls_existing.

    READ TABLE keys INTO DATA(ls_key)
      WITH KEY %tky = ls_data-%tky.

    DATA(ls_param) = ls_key-%param.

    " 🔥 TRUNCATION + MESSAGE
    DATA(lv_text) = ls_param-LongText.

    IF lv_text IS NOT INITIAL AND strlen( lv_text ) > 250.

      lv_text = lv_text(250).

      " ✅ Show message to user
      APPEND VALUE #(
        %tky = ls_data-%tky
        %msg = new_message(
          id       = 'ZMSG'
          number   = '002'
          severity = if_abap_behv_message=>severity-warning
          v1       = 'Long Text only takes 250 characters'
        )
      ) TO reported-ewayenv.

    ENDIF.

    " Prefill popup
    IF ls_param-LongText IS INITIAL AND ls_existing IS NOT INITIAL.
      result = VALUE #( BASE result (
        %tky = ls_data-%tky
        %param-long_text = ls_existing-long_text
      ) ).
      CONTINUE.
    ENDIF.

    IF ls_existing IS INITIAL.

      APPEND VALUE #(
        %cid = |CID_{ lv_invno }|
        %key-Invno = lv_invno

        %control-Invno     = if_abap_behv=>mk-on
        %control-long_text = if_abap_behv=>mk-on

        Invno     = lv_invno
        long_text = lv_text
      ) TO lt_create.

    ELSE.

      APPEND VALUE #(
        %key-Invno = lv_invno

        %control-long_text = if_abap_behv=>mk-on
        long_text = lv_text
      ) TO lt_update.

    ENDIF.

  ENDLOOP.

  IF lt_create IS NOT INITIAL.
    MODIFY ENTITIES OF zr_tbirn_einv
      ENTITY ZrTbirnEinv
      CREATE FROM lt_create.
  ENDIF.

  IF lt_update IS NOT INITIAL.
    MODIFY ENTITIES OF zr_tbirn_einv
      ENTITY ZrTbirnEinv
      UPDATE FIELDS ( long_text )
      WITH lt_update.
  ENDIF.

  result = VALUE #( FOR row IN lt_data ( %tky = row-%tky ) ).

ENDMETHOD.

*****commented for longtext truncate for 250 length
*METHOD LongText.
*
*  DATA: lt_update   TYPE TABLE FOR UPDATE zr_tbirn_einv,
*        lt_create   TYPE TABLE FOR CREATE zr_tbirn_einv,
*        ls_existing TYPE ztb_irn_einv.
*
*  READ ENTITIES OF ZEINV_ME_FM
*    IN LOCAL MODE
*    ENTITY Ewayenv
*    FIELDS ( BillingDocument )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_data).
*
*  LOOP AT lt_data INTO DATA(ls_data).
*
*    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.
*
*    IF lv_invno IS INITIAL.
*      CONTINUE.
*    ENDIF.
*
*    " Check existing record
*    SELECT SINGLE *
*      FROM ztb_irn_einv
*      WHERE invno = @lv_invno
*      INTO @ls_existing.
*
*    READ TABLE keys INTO DATA(ls_key)
*      WITH KEY %tky = ls_data-%tky.
*
*    DATA(ls_param) = ls_key-%param.
*
*    " Prefill popup
*    IF ls_param-LongText IS INITIAL AND ls_existing IS NOT INITIAL.
*      result = VALUE #( BASE result (
*        %tky = ls_data-%tky
*        %param-long_text = ls_existing-long_text
*      ) ).
*      CONTINUE.
*    ENDIF.
*
*    IF ls_existing IS INITIAL.
*
*      " CREATE
*      APPEND VALUE #(
*        %cid = |CID_{ lv_invno }|
*        %key-Invno = lv_invno
*
*        %control-Invno    = if_abap_behv=>mk-on
*        %control-long_text = if_abap_behv=>mk-on
*
*        Invno     = lv_invno
*        long_text = ls_param-LongText
*      ) TO lt_create.
*
*    ELSE.
*
*      " UPDATE
*      APPEND VALUE #(
*        %key-Invno = lv_invno
*
*        %control-long_text = if_abap_behv=>mk-on
*        long_text = ls_param-LongText
*      ) TO lt_update.
*
*    ENDIF.
*
*  ENDLOOP.
*
*  IF lt_create IS NOT INITIAL.
*    MODIFY ENTITIES OF zr_tbirn_einv
*      ENTITY ZrTbirnEinv
*      CREATE FROM lt_create.
*  ENDIF.
*
*  IF lt_update IS NOT INITIAL.
*    MODIFY ENTITIES OF zr_tbirn_einv
*      ENTITY ZrTbirnEinv
*      UPDATE FIELDS ( long_text )
*      WITH lt_update.
*  ENDIF.
*
*  result = VALUE #( FOR row IN lt_data ( %tky = row-%tky ) ).
*
*ENDMETHOD.

*METHOD sync.
*
*  zcl_cds_db_einv=>sync_db( ).
*
*ENDMETHOD.

*METHOD sync.
*
*  DATA: lt_create TYPE TABLE FOR CREATE ZEINV_ME_FM,
*        lt_update TYPE TABLE FOR UPDATE ZEINV_ME_FM.
*
*  SELECT *
*    FROM zeinv_main
*    INTO TABLE @DATA(lt_source).
*
*  LOOP AT lt_source INTO DATA(ls_source).
*
*    " Check if already exists
*    SELECT SINGLE billing_document
*      FROM ztb_uiheader
*      WHERE billing_document = @ls_source-billingdocument
*      INTO @DATA(lv_exist).
*
*    IF sy-subrc = 0.
*
*      " UPDATE
*      APPEND VALUE #(
*        BillingDocument = ls_source-billingdocument
*
*        %control-Customer     = if_abap_behv=>mk-on
*        %control-CustomerName = if_abap_behv=>mk-on
*        %control-InvoiceDate  = if_abap_behv=>mk-on
*
*        Customer     = ls_source-customer
*        CustomerName = ls_source-customername
*        InvoiceDate  = ls_source-invoicedate
*      ) TO lt_update.
*
*    ELSE.
*
*      " CREATE
*      APPEND VALUE #(
*        %cid = |CID_{ ls_source-billingdocument }|
*
*        BillingDocument = ls_source-billingdocument
*        Customer        = ls_source-customer
*        CustomerName    = ls_source-customername
*        InvoiceDate     = ls_source-invoicedate
*      ) TO lt_create.
*
*    ENDIF.
*
*  ENDLOOP.
*
*  " RAP MODIFY
*  MODIFY ENTITIES OF ZEINV_ME_FM
*    ENTITY Ewayenv
*    CREATE FROM lt_create
*    UPDATE FROM lt_update.
*
*ENDMETHOD.

*METHOD sync.
*
*  zcl_cds_db_einv=>sync_db( ).
*
*  " Refresh UI
*  READ ENTITIES OF ZEINV_ME_FM
*    IN LOCAL MODE
*    ENTITY Ewayenv
*    ALL FIELDS
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_read).
*
*  result = VALUE #( FOR row IN lt_read ( %tky = row-%tky ) ).
*
*ENDMETHOD.

ENDCLASS.











*CLASS lhc_ewayenv DEFINITION INHERITING FROM cl_abap_behavior_handler.
*  PRIVATE SECTION.
*
*    METHODS get_instance_features FOR INSTANCE FEATURES
*
*      IMPORTING keys REQUEST requested_features FOR ewayenv RESULT result.
*
*    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
*      IMPORTING REQUEST requested_authorizations FOR ewayenv RESULT result.
*
*    METHODS cancel04 FOR MODIFY
*      IMPORTING keys FOR ACTION ewayenv~cancel04 RESULT result.
*
*    METHODS generateeway FOR MODIFY
*      IMPORTING keys FOR ACTION ewayenv~generateeway RESULT result.
*
**    METHODS sync FOR MODIFY
**      IMPORTING keys FOR ACTION ewayenv~sync.
*
*    METHODS transdetails FOR MODIFY
*      IMPORTING keys FOR ACTION ewayenv~transdetails RESULT result.
**     METHODS PrintPDF FOR MODIFY
**      IMPORTING keys FOR ACTION Ewayenv~PrintPDF RESULT result.
*ENDCLASS.
*
*CLASS lhc_ewayenv IMPLEMENTATION.
*
**  METHOD get_instance_features.
**
**
**  LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key>).
**    APPEND VALUE #(
**      %tky = <fs_key>-%tky
**      %features-%action-cancel04      = if_abap_behv=>fc-o-enabled
**      %features-%action-Transdetails  = if_abap_behv=>fc-o-enabled
**      %features-%action-GenerateEway  = if_abap_behv=>fc-o-enabled
**    ) TO result.
**  ENDLOOP.
**
**
**  ENDMETHOD.
**
*  METHOD get_global_authorizations.
*  ENDMETHOD.
*
*
**METHOD get_instance_features.
**
**  READ ENTITIES OF ZEINV_ME_FM
**    IN LOCAL MODE
**    ENTITY Ewayenv
**    FIELDS ( BillingDocument cboStatus supplytype )
**    WITH CORRESPONDING #( keys )
**    RESULT DATA(lt_data).
**
**  LOOP AT lt_data INTO DATA(ls_data).
**
**    DATA(lv_cancel)    = if_abap_behv=>fc-o-disabled.
**    DATA(lv_transport) = if_abap_behv=>fc-o-disabled.
**    DATA(lv_eway)      = if_abap_behv=>fc-o-disabled.
**
**    DATA(lv_supply) = to_upper( condense( ls_data-supplytype ) ).
**    DATA(lv_status) = condense( ls_data-cboStatus ).
**
**    IF lv_supply = 'B2B' AND lv_status = '02'.
**      lv_cancel    = if_abap_behv=>fc-o-enabled.
**      lv_transport = if_abap_behv=>fc-o-enabled.
**    ENDIF.
**
**    IF lv_supply = 'B2C'.
**      lv_cancel    = if_abap_behv=>fc-o-enabled.
**      lv_transport = if_abap_behv=>fc-o-enabled.
**    ENDIF.
**
**    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.
**
**    SELECT SINGLE transportmode
**      FROM ztb_irn_einv
**      WHERE invno = @lv_invno
**      INTO @DATA(lv_transportmode).
**
**    IF lv_transportmode IS NOT INITIAL.
**      lv_eway = if_abap_behv=>fc-o-enabled.
**    ENDIF.
**
**    APPEND VALUE #(
**      %tky = ls_data-%tky
**      %action-cancel04    = lv_cancel
**      %action-Transdetails = lv_transport
**      %action-GenerateEway = lv_eway
**    ) TO result.
**
**  ENDLOOP.
**
**ENDMETHOD.
*
*
*
*
*METHOD get_instance_features.
*
*  READ ENTITIES OF ZEINV_ME_FM
*    IN LOCAL MODE
*    ENTITY Ewayenv
*    FIELDS ( BillingDocument cboStatus supplytype BillingType )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_data).
*
*  LOOP AT lt_data INTO DATA(ls_data).
*
*    DATA(lv_cancel)    = if_abap_behv=>fc-o-disabled.
*    DATA(lv_transport) = if_abap_behv=>fc-o-disabled.
*    DATA(lv_eway)      = if_abap_behv=>fc-o-disabled.
*
*    DATA(lv_supply) = to_upper( condense( ls_data-supplytype ) ).
*    DATA(lv_status) = condense( ls_data-cboStatus ).
*    DATA(lv_btype)  = condense( ls_data-BillingType ).
*
*    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.
*
*    " Check transport details exist
*    SELECT SINGLE transportmode
*      FROM ztb_irn_einv
*      WHERE invno = @lv_invno
*      INTO @DATA(lv_transportmode).
*
*    " ===== MIGO Documents =====
*    IF lv_btype = '201' OR lv_btype = '311' OR lv_btype = '541'.
*
*      lv_cancel = if_abap_behv=>fc-o-disabled.
*      lv_transport = if_abap_behv=>fc-o-enabled.
*
*      IF lv_transportmode IS NOT INITIAL.
*        lv_eway = if_abap_behv=>fc-o-enabled.
*      ENDIF.
*
*    " ===== Billing Documents =====
*    ELSE.
*
*      IF lv_supply = 'B2B' AND lv_status = '02'.
*        lv_cancel    = if_abap_behv=>fc-o-enabled.
*        lv_transport = if_abap_behv=>fc-o-enabled.
*      ENDIF.
*
*      IF lv_supply = 'B2C'.
*        lv_cancel    = if_abap_behv=>fc-o-enabled.
*        lv_transport = if_abap_behv=>fc-o-enabled.
*      ENDIF.
*
*      IF lv_transportmode IS NOT INITIAL.
*        lv_eway = if_abap_behv=>fc-o-enabled.
*      ENDIF.
*
*    ENDIF.
*
*    APPEND VALUE #(
*      %tky = ls_data-%tky
*      %action-cancel04     = lv_cancel
*      %action-Transdetails = lv_transport
*      %action-GenerateEway = lv_eway
*    ) TO result.
*
*  ENDLOOP.
*
*ENDMETHOD.
*
*METHOD cancel04.
*
*  READ ENTITIES OF ZEINV_ME_FM
*    IN LOCAL MODE
*    ENTITY Ewayenv
*    FIELDS ( BillingDocument )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_data).
*
*  DATA lt_update TYPE TABLE FOR UPDATE ZR_TBIRN_EINV.
*
*  LOOP AT lt_data INTO DATA(ls_data).
*
*    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.
*
*    APPEND VALUE #(
*      invno  = lv_invno
*      status = '04'
*    ) TO lt_update.
*
*  ENDLOOP.
*
*  MODIFY ENTITIES OF ZR_TBIRN_EINV
*    ENTITY ZrTbirnEinv
*    UPDATE FIELDS ( status )
*    WITH lt_update.
*
*  result = VALUE #(
*    FOR row IN lt_data
*    ( %tky = row-%tky )
*  ).
*
*ENDMETHOD.
*
*METHOD GenerateEway.
*
*  DATA lt_update TYPE TABLE FOR UPDATE ZR_TBIRN_EINV.
*
*  " Read Billing Document from UI
*  READ ENTITIES OF ZEINV_ME_FM
*    IN LOCAL MODE
*    ENTITY Ewayenv
*    FIELDS ( BillingDocument )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_data).
*
*  LOOP AT lt_data INTO DATA(ls_data).
*
*    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.
*
*    APPEND VALUE #(
*      invno          = lv_invno
*      ewaybillstatus = '01'
*    ) TO lt_update.
*
*  ENDLOOP.
*
*  MODIFY ENTITIES OF ZR_TBIRN_EINV
*    ENTITY ZrTbirnEinv
*    UPDATE FIELDS ( ewaybillstatus )
*    WITH lt_update.
*
*  result = VALUE #(
*    FOR row IN lt_data
*    ( %tky = row-%tky )
*  ).
*
*ENDMETHOD.
*
**  METHOD sync.
**  ENDMETHOD.
*
*METHOD Transdetails.
*
*  DATA: lt_update   TYPE TABLE FOR UPDATE zr_tbirn_einv,
*        lt_create   TYPE TABLE FOR CREATE zr_tbirn_einv,
*        ls_existing TYPE ztb_irn_einv.
*
*  " Step 1: Read Billing Document
*  READ ENTITIES OF ZEINV_ME_FM
*    IN LOCAL MODE
*    ENTITY Ewayenv
*    FIELDS ( BillingDocument )
*    WITH CORRESPONDING #( keys )
*    RESULT DATA(lt_data).
*
*  LOOP AT lt_data INTO DATA(ls_data).
*
*    DATA(lv_invno) = |{ ls_data-BillingDocument ALPHA = IN }|.
*
*    IF lv_invno IS INITIAL.
*      CONTINUE.
*    ENDIF.
*
*    " Step 2: Check if already exists
*    CLEAR ls_existing.
*    SELECT SINGLE *
*      FROM ztb_irn_einv
*      WHERE invno = @lv_invno
*      INTO @ls_existing.
*
*    " Step 3: Read popup parameters
*    READ TABLE keys INTO DATA(ls_key)
*      WITH KEY %tky = ls_data-%tky.
*
*    IF sy-subrc <> 0.
*      CONTINUE.
*    ENDIF.
*
*    DATA(ls_param) = ls_key-%param.
*
**    " Step 4: If popup open without values → Prefill
**IF ls_key-%param-TransportMode IS INITIAL
**   AND ls_key-%param-VehicleNumber IS INITIAL
**   AND ls_key-%param-TransportCode IS INITIAL.
**
**  result = VALUE #( BASE result (
**    %tky = ls_data-%tky
**    %param-TransportMode         = ls_existing-transportmode
**    %param-VehicleType           = ls_existing-vehicletype
**    %param-VehicleNumber         = ls_existing-vehiclenumber
**    %param-TransportCode         = ls_existing-transportcode
**    %param-TransportName         = ls_existing-transportname
**    %param-TransportId           = ls_existing-transportid
**    %param-TransportDocketNumber = ls_existing-transportdocketnumber
**    %param-TransportDocketDate   = ls_existing-transportdocketdate
**  ) ).
**
**  RETURN.
**ENDIF.
**
**
**" Step 5: Create or Update WITH transport details (FIRST TIME ITSELF)
**
**IF ls_existing IS INITIAL.
**
**  " CREATE with transport details
**  APPEND VALUE #(
**    %cid = |CID_{ lv_invno }|
**    %key-Invno = lv_invno
**    %control-Invno = if_abap_behv=>mk-on
**
**    Invno = lv_invno
**    Ackno = lv_invno
**
**    transportmode          = ls_param-TransportMode
**    vehicletype            = ls_param-VehicleType
**    vehiclenumber          = ls_param-VehicleNumber
**    transportcode          = ls_param-TransportCode
**    transportname          = ls_param-TransportName
**    transportid            = ls_param-TransportId
**    transportdocketnumber  = ls_param-TransportDocketNumber
**    transportdocketdate    = ls_param-TransportDocketDate
**  ) TO lt_create.
**
**ELSE.
**
**  " UPDATE with control fields
**  APPEND VALUE #(
**    %key-Invno = lv_invno
**
**    %control-transportmode         = if_abap_behv=>mk-on
**    %control-vehicletype           = if_abap_behv=>mk-on
**    %control-vehiclenumber         = if_abap_behv=>mk-on
**    %control-transportcode         = if_abap_behv=>mk-on
**    %control-transportname         = if_abap_behv=>mk-on
**    %control-transportid           = if_abap_behv=>mk-on
**    %control-transportdocketnumber = if_abap_behv=>mk-on
**    %control-transportdocketdate   = if_abap_behv=>mk-on
**
**    transportmode          = ls_param-TransportMode
**    vehicletype            = ls_param-VehicleType
**    vehiclenumber          = ls_param-VehicleNumber
**    transportcode          = ls_param-TransportCode
**    transportname          = ls_param-TransportName
**    transportid            = ls_param-TransportId
**    transportdocketnumber  = ls_param-TransportDocketNumber
**    transportdocketdate    = ls_param-TransportDocketDate
**  ) TO lt_update.
**
**ENDIF.
*
*    " Step 4: If popup opened first time → Prefill
*    IF ls_param IS INITIAL.
*
*      result = VALUE #( BASE result (
*        %tky = ls_data-%tky
*        %param-TransportMode         = ls_existing-transportmode
*        %param-VehicleType           = ls_existing-vehicletype
*        %param-VehicleNumber         = ls_existing-vehiclenumber
*        %param-TransportCode         = ls_existing-transportcode
*        %param-TransportName         = ls_existing-transportname
*        %param-TransportId           = ls_existing-transportid
*        %param-TransportDocketNumber = ls_existing-transportdocketnumber
*        %param-TransportDocketDate   = ls_existing-transportdocketdate
*      ) ).
*
*      CONTINUE.
*    ENDIF.
*
*    " Step 5: Create or Update
*
*    IF ls_existing IS INITIAL.
*
*      " CREATE
*      APPEND VALUE #(
*        %cid = |CID_{ lv_invno }|
*        %key-Invno = lv_invno
*        %control-Invno = if_abap_behv=>mk-on
*        Invno = lv_invno
*
*        transportmode          = ls_param-TransportMode
*        vehicletype            = ls_param-VehicleType
*        vehiclenumber          = ls_param-VehicleNumber
*        transportcode          = ls_param-TransportCode
*        transportname          = ls_param-TransportName
*        transportid            = ls_param-TransportId
*        transportdocketnumber  = ls_param-TransportDocketNumber
*        transportdocketdate    = ls_param-TransportDocketDate
*      ) TO lt_create.
*
*    ELSE.
*
*      " UPDATE
*      APPEND VALUE #(
*        %key-Invno = lv_invno
*        transportmode          = ls_param-TransportMode
*        vehicletype            = ls_param-VehicleType
*        vehiclenumber          = ls_param-VehicleNumber
*        transportcode          = ls_param-TransportCode
*        transportname          = ls_param-TransportName
*        transportid            = ls_param-TransportId
*        transportdocketnumber  = ls_param-TransportDocketNumber
*        transportdocketdate    = ls_param-TransportDocketDate
*      ) TO lt_update.
*
*    ENDIF.
*
*  ENDLOOP.
*
*  " Step 6: Save to DB
*  IF lt_create IS NOT INITIAL.
*    MODIFY ENTITIES OF zr_tbirn_einv
*      ENTITY ZrTbirnEinv
*      CREATE FROM lt_create.
*  ENDIF.
*
*  IF lt_update IS NOT INITIAL.
*    MODIFY ENTITIES OF zr_tbirn_einv
*      ENTITY ZrTbirnEinv
*      UPDATE FIELDS (
*        transportmode
*        vehicletype
*        vehiclenumber
*        transportcode
*        transportname
*        transportid
*        transportdocketnumber
*        transportdocketdate
*      )
*      WITH lt_update.
*  ENDIF.
*
*  " Step 7: Return
*  result = VALUE #( FOR row IN lt_data ( %tky = row-%tky ) ).
*
*ENDMETHOD.
*
*
**METHOD PrintPDF.
**
**  DATA lt_data TYPE TABLE FOR READ RESULT ZEINV_ME_FM.
**
**  READ ENTITIES OF ZEINV_ME_FM
**    IN LOCAL MODE
**    ENTITY ZEINV_ME_FM
**    FIELDS ( BillingDocument )
**    WITH CORRESPONDING #( keys )
**    RESULT lt_data.
**
**  LOOP AT lt_data INTO DATA(ls_data).
**
**    DATA(lv_inv) = |{ ls_data-BillingDocument ALPHA = IN }|.
**
**    DATA(lv_url) = |/sap/opu/odata4/sap/zce_form_einv_sb_api/srvd_a2x/sap/zce_form_einv_sd/0001/ZCE_FORM_EINV('{ lv_inv }')/form|.
**
**    DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
**                      comm_scenario  = 'ZCS_EINVPDF'
**                      comm_system_id = 'INTEGRATION'
**                      service_id     = 'ZCE_FORM_EINV_SB_API' ).
**
**    DATA(lo_http) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
**
**    lo_http->get_http_request( )->set_uri_path( lv_url ).
**
**    DATA(lo_resp) = lo_http->execute( if_web_http_client=>get ).
**
**    DATA(lv_pdf) = lo_resp->get_binary( ).
**
**    APPEND VALUE #(
**      %tky = ls_data-%tky
**      %param-filecontent = lv_pdf
**      %param-filename = |Invoice_{ lv_inv }.pdf|
**      %param-mimetype = 'application/pdf'
**    ) TO result.
**
**  ENDLOOP.
**
**ENDMETHOD.
*
*ENDCLASS.
