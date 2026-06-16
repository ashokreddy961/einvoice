***CLASS zcl_cds_db_einv DEFINITION
***  PUBLIC
***  FINAL
***  CREATE PUBLIC .
***
***  PUBLIC SECTION.
***  PROTECTED SECTION.
***  PRIVATE SECTION.
***ENDCLASS.
***
***
***
***CLASS zcl_cds_db_einv IMPLEMENTATION.
***ENDCLASS.
*


CLASS zcl_cds_db_einv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.
    INTERFACES if_rap_query_provider.
    " ✅ Static method
    CLASS-METHODS sync_db.
PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_CDS_DB_EINV IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

    TRY.


        " ✅ Correct static call
        zcl_cds_db_einv=>sync_db( ).

        COMMIT WORK.

        out->write( 'Sync Completed Successfully!' ).

      CATCH cx_root INTO DATA(lx_error).

        DATA(lv_text) = lx_error->get_text( ).
        out->write( lv_text ).

    ENDTRY.

  ENDMETHOD.


METHOD if_rap_query_provider~select.

  DATA: lt_result TYPE STANDARD TABLE OF zce_form_einv,
        ls_result TYPE zce_form_einv,
        lt_bill   TYPE STANDARD TABLE OF vbeln_va,
        lv_bill   TYPE vbeln_va,
        lv_offset TYPE i,
        lv_limit  TYPE i,
        lv_total  TYPE int8,
        lt_empty  TYPE STANDARD TABLE OF zce_form_einv.

  DATA lv_bill_filter TYPE vbeln_va.
  DATA lv_fisc_filter TYPE datum.



*---------------------------------------------------------------------*
* Paging
*---------------------------------------------------------------------*
  DATA(lo_paging) = io_request->get_paging( ).

  lv_offset = lo_paging->get_offset( ).
  lv_limit  = lo_paging->get_page_size( ).

  IF lv_offset < 0.
    lv_offset = 0.
  ENDIF.

  IF lv_limit <= 0.
    lv_limit = 500.
  ENDIF.



*TRY.
*    lv_bill_filter = io_request->get_entity_id( ).
*  CATCH cx_rap_query_provider INTO DATA(lx_qp).
*    lv_bill_filter = ''.
*ENDTRY.
DATA lo_filter TYPE REF TO if_rap_query_filter.

lo_filter = io_request->get_filter( ).

IF lo_filter IS BOUND.

  TRY.
      DATA(lt_filter) = lo_filter->get_as_ranges( ).

LOOP AT lt_filter INTO DATA(ls_filter).

  IF ls_filter-name = 'BILLING_DOCUMENT'.
    READ TABLE ls_filter-range INTO DATA(ls_range) INDEX 1.
    IF sy-subrc = 0.
      lv_bill_filter = ls_range-low.
    ENDIF.
  ENDIF.

*  IF ls_filter-name = 'INVOICE_DATE'.
*    READ TABLE ls_filter-range INTO ls_range INDEX 1.
*    IF sy-subrc = 0.
*      lv_fisc_filter = ls_range-low.
*    ENDIF.
*  ENDIF.

ENDLOOP.


CATCH cx_rap_query_filter_no_range INTO DATA(lx_filter).
  " no filter provided
  lv_bill_filter = ''.
ENDTRY.
ENDIF.

*---------------------------------------------------------------------*
* PDF MODE
*---------------------------------------------------------------------*
  DATA(req_fields) = io_request->get_requested_elements( ).

  IF line_exists( req_fields[ table_line = 'FORM' ] ).

    IF lv_bill_filter IS INITIAL.

      io_response->set_data( lt_empty ).
      io_response->set_total_number_of_records( 0 ).
      RETURN.


    ENDIF.

    DATA lv_layout TYPE xstring.
    DATA lv_xml    TYPE xstring.
    DATA lv_pdf    TYPE xstring.



* Read Form Layout
    TRY.

        DATA(lo_reader) = cl_fp_form_reader=>create_form_reader(
                            iv_formname = 'ZFM_OBJ_EINV' ).

        lv_layout = lo_reader->get_layout( ).

      CATCH cx_fp_form_reader.

        io_response->set_data( lt_empty ).
        io_response->set_total_number_of_records( 0 ).
        RETURN.

    ENDTRY.


DATA lo_fdp_api TYPE REF TO if_fp_fdp_api.

TRY.

    lo_fdp_api = cl_fp_fdp_services=>get_instance(
                   iv_service_definition = 'ZEINV_FORM_SD'
                   iv_max_depth          = 1 ).

  CATCH cx_fp_fdp_error INTO DATA(lx_fdp).

    io_response->set_data( lt_empty ).
    io_response->set_total_number_of_records( 0 ).
    RETURN.

ENDTRY.

IF lv_bill_filter IS INITIAL .
*OR lv_fisc_filter IS INITIAL.

  io_response->set_data( lt_empty ).
  io_response->set_total_number_of_records( 0 ).
  RETURN.

ENDIF.

* Set Key
    DATA(lt_keys) = lo_fdp_api->get_keys( ).

    TRY.

*        lt_keys[ name = 'BILLINGDOCUMENT' ]-value = lv_bill_filter.
lt_keys[ name = 'BILLINGDOCUMENT' ]-value = lv_bill_filter.
*lt_keys[ name = 'INVOICEDATE' ]-value     = lv_fisc_filter.

      CATCH cx_sy_itab_line_not_found.

        io_response->set_data( lt_empty ).
        io_response->set_total_number_of_records( 0 ).
        RETURN.

    ENDTRY.



* Convert CDS → XML
    TRY.

        lv_xml = lo_fdp_api->read_to_xml_v2(
                   it_select = lt_keys ).

      CATCH cx_fp_fdp_error.

        io_response->set_data( lt_empty ).
        io_response->set_total_number_of_records( 0 ).
        RETURN.

    ENDTRY.



* Render PDF
    TRY.

        cl_fp_ads_util=>render_pdf(
          EXPORTING
            iv_xml_data   = lv_xml
            iv_xdp_layout = lv_layout
            iv_locale     = 'EN'
          IMPORTING
            ev_pdf        = lv_pdf ).

      CATCH cx_fp_ads_util.

        io_response->set_data( lt_empty ).
        io_response->set_total_number_of_records( 0 ).
        RETURN.

    ENDTRY.


* Return PDF
    CLEAR ls_result.

    DATA lv_docref TYPE ztb_uiheader-documentreferenceid.

    SELECT SINGLE documentreferenceid

      FROM ztb_uiheader
      WHERE billing_document = @lv_bill_filter
       INTO @lv_docref.

    ls_result-billing_document = lv_bill_filter.

    IF lv_docref IS NOT INITIAL.
      ls_result-filename = |INV_{ lv_docref }.pdf|.
    ELSE.
      ls_result-filename = |INV_{ lv_bill_filter }.pdf|.
    ENDIF.

    ls_result-mimetype = 'application/pdf'.
    ls_result-form     = lv_pdf.

***commented for filename 20/5
** Return PDF
*    CLEAR ls_result.
*
*    ls_result-billing_document = lv_bill_filter.
*    ls_result-filename = |INV_{ lv_bill_filter }.pdf|.
*    ls_result-mimetype = 'application/pdf'.
*    ls_result-form     = lv_pdf.
*
    APPEND ls_result TO lt_result.

    io_response->set_data( lt_result ).
    io_response->set_total_number_of_records( 1 ).

    RETURN.

  ENDIF.



SELECT COUNT(*)
  FROM ztb_uiheader
  WHERE billing_document IS NOT INITIAL
    INTO @lv_total.



  SELECT billing_document,
  documentreferenceid
*  ,invoice_date
    FROM ztb_uiheader
      WHERE billing_document IS NOT INITIAL

    ORDER BY billing_document
*    INTO TABLE @lt_bill
      INTO TABLE @DATA(lt_data)
    OFFSET @lv_offset
    UP TO @lv_limit ROWS.



*  LOOP AT lt_bill INTO lv_bill.
LOOP AT lt_data INTO DATA(ls_data).
    CLEAR ls_result.

      DATA(lv_filename_ref) = ls_data-billing_document.

  IF ls_data-documentreferenceid IS NOT INITIAL.
    lv_filename_ref = ls_data-documentreferenceid.
  ENDIF.

  ls_result-billing_document = ls_data-billing_document.
  ls_result-filename         = |INV_{ lv_filename_ref }.pdf|.
  ls_result-mimetype         = 'application/pdf'.
  ls_result-form             = ''.

  APPEND ls_result TO lt_result.

ENDLOOP.

*    ls_result-billing_document = ls_data-billing_document.
**    ls_result-invoice_date     = ls_data-invoice_date.
**    ls_result-filename = |INV_{ lv_bill }.pdf|.
*    ls_result-filename = |INV_{ ls_data-billing_document }.pdf|.
*    ls_result-mimetype = 'application/pdf'.
*    ls_result-form     = ''.
*
*    APPEND ls_result TO lt_result.
*
*  ENDLOOP.


  io_response->set_data( lt_result ).
  io_response->set_total_number_of_records( lv_total ).

ENDMETHOD.


  METHOD sync_db.

    TRY.

        DATA: lt_head_update TYPE TABLE OF ztb_uiheader ,
              lt_item_update TYPE TABLE OF ztb_uiitem.
*              lt_irn_update TYPE TABLE FOR UPDATE zr_tbirn_einv.
              DATA: lt_annex_update TYPE TABLE OF ztb_annexure.
*--------------------------------------------------------------------*
* Fetch billing data
*--------------------------------------------------------------------*
        SELECT *
          FROM zeinv_main
          WHERE billingdocument IS NOT INITIAL
          INTO TABLE @DATA(lt_source).

        IF lt_source IS INITIAL.
          RETURN.
        ENDIF.

*--------------------------------------------------------------------*
* Clean old data (Full refresh)
*--------------------------------------------------------------------*
        DELETE FROM ztb_uiitem WHERE billingdoc IS NOT INITIAL.
DELETE FROM ztb_uiheader WHERE billing_document IS NOT INITIAL.
DELETE FROM ztb_annexure WHERE billingdoc IS NOT INITIAL.

*--------------------------------------------------------------------*
* Build Header + Item
*--------------------------------------------------------------------*


SORT lt_source BY billingdocument billingdocumentitem.

LOOP AT lt_source ASSIGNING FIELD-SYMBOL(<s>).

  DATA lv_supplytype TYPE c LENGTH 3.
  DATA lv_status     TYPE c LENGTH 2.

  lv_supplytype = <s>-SupplyType.
  lv_status     = '01'.   " Default Yet to Post



*------------------- HEADER -------------------*
          READ TABLE lt_head_update  ASSIGNING FIELD-SYMBOL(<h>)
            WITH KEY billing_document = <s>-billingdocument
            invoice_date       = <s>-invoicedate.
*            TRANSPORTING NO FIELDS.

          IF sy-subrc <> 0.

            APPEND VALUE ztb_uiheader(

              client               = sy-mandt
              billing_document     = <s>-billingdocument
              company_code_name    = <s>-companycodename
              company_gstin        = <s>-companygstin
              plant                = <s>-plant
              plant_name           = <s>-plantname
              city_name            = <s>-cityname
              district_name        = <s>-districtname
              postal_code          = <s>-postalcode
              street_name          = <s>-streetname
              street_prefix1      =  <s>-StreetPrefixName1
              street_prefix2      = <s>-StreetPrefixName2
              street_suffix1      = <s>-StreetSuffixName1
              OrganizationName1   = <s>-OrganizationName1
              customer             = <s>-customer
              customer_name        = <s>-customername
              customer_gstin       = <s>-taxnumber3
              customer_street     =  <s>-customerstreetname
  customer_city        =   <s>-customercity
  customer_postal      = <s>-customerpost
  customer_house_no    = <s>-CustomerHouse
  customer_district    = <s>-CustomerDistrict
  customer_region      = <s>-CustomerRegion
  customer_country     = <s>-CustomerCountry
  customer_street1     = <s>-customerSTREET1
  customer_street2     = <s>-customerSTREET2
  customer_street3    = <s>-customerSTREET3
  customer_street4     = <s>-customerSTREET4
              invoice_date         = <s>-invoicedate
              payment_terms        = <s>-paymenttermsname
              place_of_supply      = <s>-placeofsupply
              po_date              = <s>-yy1_po_date_bdi
              po_number            = <s>-yy1_po_num_bdi
              transaction_currency = <s>-transactioncurrency
              billingdocumenttype  = <s>-billingdocumenttype
              last_changed_at      = <s>-lastchangedatetime
              documentreferenceid  = <s>-documentreferenceid
              billto_name          = <s>-billtoname
              billto_street        = <s>-billtostreet
              billto_house_no      = <s>-billtohouseno
              billto_city          = <s>-billtocity
              billto_district      = <s>-billtodistrict
              billto_region        = <s>-billtoregion
              billto_postal_code   = <s>-billtopostalcode
              billto_country       = <s>-billtocountry
              billto_street1       = <s>-billtostreet1
              billto_street2       = <s>-billtostreet2
              billto_street3       = <s>-billtostreet3
              billto_street4      = <s>-billtostreet4
              billto_gstin       = <s>-billtogstin
              shipto_customer      = <s>-shiptocustomer
              shipto_name          = <s>-shiptoname
              shipto_street        = <s>-shiptostreet
              shipto_house_no      = <s>-shiptohouseno
              shipto_city          = <s>-shiptocity
              shipto_district      = <s>-shiptodistrict
              shipto_region        = <s>-shiptoregion
              shipto_postal_code   = <s>-shiptopostalcode
              shipto_country       = <s>-shiptocountry
              shipto_street1       = <s>-shiptostreet1
              shipto_street2      = <s>-shiptostreet2
              shipto_street3      = <s>-shiptostreet3
              shipto_street4      = <s>-shiptostreet4

                   soldto_customer      = <s>-payertocustomer
             soldto_name          = <s>-payertoname
              soldto_street        = <s>-payertostreet
             soldto_house_no      = <s>-payertohouseno
              soldto_city          = <s>-payertocity
              soldto_district      = <s>-payertodistrict
              soldto_region        = <s>-payertoregion
              soldto_postal_code   = <s>-payerPostalCode
              soldto_country       = <s>-payerCountry
              soldto_street1       = <s>-payerSTREET1
              soldto_street2      = <s>-payerSTREET2
              soldto_street3      = <s>-payerSTREET3
              soldto_street4      = <s>-payerSTREET4
              companycode          = <s>-companycode
              fiscalyear           = <s>-fiscalyear

              supplytype           = lv_supplytype

              docrefidf2           = <s>-f2referenceddocument
              orginalinvoicedate   = <s>-orginalinvoicedate
              customergroup        = <s>-customergroup
              customergrouptext    = <s>-customergrouptext
              paymentduedate      = <s>-PaymentDueDate
              housebank         = <s>-HouseBank
              bank_account        =  <s>-BankAccount
              bank_name           =  <s>-BankName
              neft_ifsc_rtgs_code = <s>-ifsc
              yy1_customeraddresspo_pdh = <s>-YY1_CustomerAddresspo_PDH
              yy1_customernamepo_pdh = <s>-YY1_CustomerNamepo_PDH
             supplying_plant         = <s>-SupplyingPlant
             invoicereversal     = <s>-invoicereversal
             lutnumber     = <s>-LUTNo
             referencecodeyear = <s>-referencecodeyear
             wbs_element_desc = <s>-wbs_element_desc
             wbs_element_id = <s>-wbs_element_id
             wbs_element_name = <s>-wbs_element_name


            ) TO lt_head_update.

            ELSE.

  " ✅ UPDATE HEADER (THIS IS YOUR FIX)
  IF <h>-housebank IS INITIAL AND <s>-HouseBank IS NOT INITIAL.
    <h>-housebank = <s>-HouseBank.
  ENDIF.

  IF <h>-bank_account IS INITIAL AND <s>-BankAccount IS NOT INITIAL.
    <h>-bank_account = <s>-BankAccount.
  ENDIF.

  IF <h>-bank_name IS INITIAL AND <s>-BankName IS NOT INITIAL.
    <h>-bank_name = <s>-BankName.
  ENDIF.

  IF <h>-neft_ifsc_rtgs_code IS INITIAL AND <s>-ifsc IS NOT INITIAL.
    <h>-neft_ifsc_rtgs_code = <s>-ifsc.
  ENDIF.

          ENDIF.

*------------------- ITEM -------------------*
          APPEND VALUE ztb_uiitem(

            client                = sy-mandt
            billingdoc            = <s>-billingdocument
            billing_document_item = <s>-billingdocumentitem
            itemcode              = <s>-itemcode
            item_text             = <s>-billingdocumentitemtext
            billing_quantity      = <s>-billingquantity
            billing_quantity_unit = <s>-billingquantityunit
            transaction_currency  = <s>-transactioncurrency
            net_amount            = <s>-netamount
            hsn_code              = <s>-hsncode
            net_price_amount      = <s>-netpriceamount
            cgst_amount           = <s>-cgstamount
            sgst_amount           = <s>-sgstamount
            igst_amount           = <s>-igstamount
            cgst_rate             = <s>-cgst_rate
            sgst_rate             = <s>-sgst_rate
            igst_rate             = <s>-igst_rate
            freightamount        = <s>-FreightAmount
            uom                   = <s>-uom
            tcsamount             = <s>-tcsamount
            taxcode               = <s>-taxcode
            glaccountname         = <s>-glaccountname
            invoicetotal          = <s>-invoicetotal
            jeassignmentreference = <s>-JEAssignmentReference
            taxindicator         = <s>-taxindicator


          ) TO lt_item_update.

        ENDLOOP.

SORT lt_source BY billingdocument annexurematerialdocumentitem.

DELETE ADJACENT DUPLICATES FROM lt_source
  COMPARING billingdocument annexurematerialdocumentitem.

DATA lv_sno TYPE i.

LOOP AT lt_source INTO DATA(ls_src)
  WHERE AnnexureMaterialDocumentItem IS NOT INITIAL.

  AT NEW billingdocument.
    lv_sno = 1.
  ENDAT.

  APPEND VALUE ztb_annexure(
    client      = sy-mandt
    billingdoc  = ls_src-billingdocument
    sno         = lv_sno
    annexmaterialdocumentitem = ls_src-AnnexureMaterialDocumentItem
    annexmaterial             = ls_src-AnnexureMaterial
    annex_desc                = ls_src-AnnexureDesc
    annex_qty                 = ls_src-AnnexureQty
    annex_uom                 = ls_src-AnnexureUOM
    annex_hsn                 = ls_src-AnnexureHSN
    annex_batch               = ls_src-AnnexureBatch
  ) TO lt_annex_update.

  lv_sno = lv_sno + 1.

ENDLOOP.





*--------------------------------------------------------------------*
* Remove duplicate headers
*--------------------------------------------------------------------*
        SORT lt_head_update BY billing_document.
        DELETE ADJACENT DUPLICATES FROM lt_head_update COMPARING billing_document .
*        invoice_date.

*--------------------------------------------------------------------*
* Update DB
*--------------------------------------------------------------------*
        IF lt_head_update IS NOT INITIAL.
          MODIFY ztb_uiheader FROM TABLE @lt_head_update.
        ENDIF.

        IF lt_item_update IS NOT INITIAL.
          MODIFY ztb_uiitem FROM TABLE @lt_item_update.
        ENDIF.


        IF lt_annex_update IS NOT INITIAL.
  MODIFY ztb_annexure FROM TABLE @lt_annex_update.
ENDIF.

*        COMMIT WORK.

      CATCH cx_root INTO DATA(lx_error).

        DATA(lv_text) = lx_error->get_text( ).

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
