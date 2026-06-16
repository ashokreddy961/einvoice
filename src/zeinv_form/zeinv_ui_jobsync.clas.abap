*CLASS zeinv_ui_jobsync DEFINITION
*  PUBLIC
*  FINAL
*  CREATE PUBLIC .
*
*  PUBLIC SECTION.
*  PROTECTED SECTION.
*  PRIVATE SECTION.
*ENDCLASS.
*
*
*
*CLASS zeinv_ui_jobsync IMPLEMENTATION.
*ENDCLASS.




CLASS zeinv_ui_jobsync DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_apj_dt_exec_object.
    INTERFACES if_apj_rt_exec_object.

  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS ZEINV_UI_JOBSYNC IMPLEMENTATION.


  METHOD if_apj_dt_exec_object~get_parameters.
    " No parameters needed for sync job
  ENDMETHOD.


  METHOD if_apj_rt_exec_object~execute.

    TRY.

        " Call your sync method
        zcl_cds_db_einv=>sync_db( ).

        COMMIT WORK.

      CATCH cx_root INTO DATA(lx_error).

        DATA(lv_error_text) = lx_error->get_text( ).

*        " Optional: write log
*        cl_apj_rt_api=>log_message(
*          EXPORTING
*            iv_msg_type = 'E'
*            iv_msg_text = lv_error_text ).

    ENDTRY.

  ENDMETHOD.
ENDCLASS.
