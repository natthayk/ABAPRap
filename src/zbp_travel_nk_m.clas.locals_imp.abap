CLASS lsc_zi_travel_nk_m DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

ENDCLASS.

CLASS lsc_zi_travel_nk_m IMPLEMENTATION.

  METHOD save_modified.
    DATA: lt_zlog_travel_r   TYPE STANDARD TABLE OF zlog_travel_r,
          lt_zlog_travel_upd TYPE STANDARD TABLE OF zlog_travel_r.

    IF create-zi_travel_nk_m IS NOT INITIAL.
      lt_zlog_travel_r = CORRESPONDING #( create-zi_travel_nk_m ).
      LOOP AT lt_zlog_travel_r ASSIGNING FIELD-SYMBOL(<ls_zlog_travel_r>).

        <ls_zlog_travel_r>-changing_operation = 'CREATE'.
        GET TIME STAMP FIELD <ls_zlog_travel_r>-created_at.

        READ TABLE create-zi_travel_nk_m ASSIGNING FIELD-SYMBOL(<ls_travel>)
                                         WITH TABLE KEY entity
                                         COMPONENTS TravelId = <ls_zlog_travel_r>-travelid.
        IF sy-subrc = 0.
          IF <ls_travel>-%control-BookingFee = cl_abap_behv=>flag_changed.
            <ls_zlog_travel_r>-changed_field_name = 'BookingFee'.
            <ls_zlog_travel_r>-changed_value      = <ls_travel>-BookingFee.
            TRY.
                <ls_zlog_travel_r>-change_id          = cl_system_uuid=>create_uuid_x16_static( ).
              CATCH cx_uuid_error.
                "handle exception
            ENDTRY.

            APPEND <ls_zlog_travel_r> TO lt_zlog_travel_upd.

          ENDIF.
        ENDIF.
      ENDLOOP.

      INSERT zlog_travel_R FROM TABLE @lt_zlog_travel_upd.

    ENDIF.

    IF update-zi_travel_nk_m IS NOT INITIAL.

    ENDIF.

    IF delete-zi_travel_nk_m IS NOT INITIAL.

    ENDIF.

******************************************************************************************
*     For Unmanage Save zi_booksupp_nk_m
******************************************************************************************

    DATA: lt_book_suppl TYPE STANDARD TABLE OF zhr_booksuppl_m.
    IF create-zi_booksupp_nk_m IS NOT INITIAL.

      lt_book_suppl = VALUE #( FOR ls_booksup IN  create-zi_booksupp_nk_m (
                                                      travel_id  = ls_booksup-TravelId
                                                      booking_id = ls_booksup-BookingId
                                                      booking_supplement_id  = ls_booksup-BookingSupplementId
                                                      supplement_id   = ls_booksup-SupplementId
                                                      price   = ls_booksup-Price
                                                      currency_code    = ls_booksup-CurrencyCode
                                                      last_changed_at = ls_booksup-LastChangedAt
                                                )
                                ).

      INSERT zhr_booksuppl_m FROM TABLE  @lt_book_suppl."Or we can call function module to update

    ENDIF.

    IF update-zi_booksupp_nk_m IS NOT INITIAL.

      lt_book_suppl = VALUE #( FOR ls_booksup IN  update-zi_booksupp_nk_m (
                                          travel_id  = ls_booksup-TravelId
                                          booking_id = ls_booksup-BookingId
                                          booking_supplement_id  = ls_booksup-BookingSupplementId
                                          supplement_id   = ls_booksup-SupplementId
                                          price   = ls_booksup-Price
                                          currency_code    = ls_booksup-CurrencyCode
                                          last_changed_at = ls_booksup-LastChangedAt
                                            )  ).

      UPDATE zhr_booksuppl_m FROM TABLE @lt_book_suppl.

    ENDIF.

    IF delete-zi_booksupp_nk_m IS NOT INITIAL.


      lt_book_suppl = VALUE #( FOR ls_del IN  delete-zi_booksupp_nk_m (
                                          travel_id  = ls_del-TravelId
                                          booking_id = ls_del-BookingId
                                          booking_supplement_id  = ls_del-BookingSupplementId
                                            )  ).

      DELETE  zhr_booksuppl_m FROM TABLE @lt_book_suppl.

    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lhc_zi_travel_nk_m DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_travel_nk_m RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_travel_nk_m RESULT result.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR zi_travel_nk_m RESULT result.

     METHODS get_global_features FOR GLOBAL FEATURES
      IMPORTING REQUEST requested_features FOR zi_travel_nk_m RESULT result.

    METHODS accepttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_nk_m~accepttravel RESULT result.

    METHODS copytravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_nk_m~copytravel.

    METHODS recalctotprice FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_nk_m~recalctotprice.

    METHODS rejecttravel FOR MODIFY
      IMPORTING keys FOR ACTION zi_travel_nk_m~rejecttravel RESULT result.
    METHODS validatecustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_nk_m~validatecustomer.
    METHODS validatebookingfee FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_nk_m~validatebookingfee.

    METHODS validatecurencycode FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_nk_m~validatecurencycode.

    METHODS validatedates FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_nk_m~validatedates.

    METHODS validatestatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR zi_travel_nk_m~validatestatus.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_travel_nk_m~calculatetotalprice.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_nk_m\_booking.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE zi_travel_nk_m.

ENDCLASS.

CLASS lhc_zi_travel_nk_m IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.


  METHOD validateCustomer.

    DATA: lt_cust TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    READ ENTITIES OF zI_travel_nk_m IN LOCAL MODE
    ENTITY zI_travel_nk_m
    FIELDS ( CustomerId  )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).


    lt_cust = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId ).
    CHECK NOT lt_cust IS INITIAL.
    SELECT FROM /dmo/customer
    FIELDS customer_id
    FOR ALL ENTRIES IN @lt_cust
    WHERE customer_id = @lt_cust-customer_id
    INTO TABLE @DATA(lt_valid_db).
    IF sy-subrc = 0.
    ENDIF.
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      IF <ls_travel>-CustomerId IS INITIAL OR
        NOT line_exists( lt_valid_db[ customer_id = <ls_travel>-CustomerId ]  ).

        APPEND VALUE #( %tky = <ls_travel>-%tky )
               TO failed-zi_travel_nk_m.

        APPEND VALUE #( %tky = <ls_travel>-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                      textid                = /dmo/cm_flight_messages=>customer_unkown
                                      customer_id           = <ls_travel>-CustomerId
                                      severity              = if_abap_behv_message=>severity-error
                               )
                        %element-customerid = if_abap_behv=>mk-on "Marking this field
                       )
               TO reported-zi_travel_nk_m.

      ENDIF.
    ENDLOOP.



  ENDMETHOD.

  METHOD earlynumbering_create.

    DATA(lt_entities) = entities.

    DELETE lt_entities WHERE TravelId IS NOT INITIAL.
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
*        ignore_buffer     =
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          = CONV #(  lines( lt_entities ) )
*        subobject         =
*        toyear            =
          IMPORTING
            number            = DATA(lv_latest_num)
            returncode        = DATA(lv_code)
            returned_quantity = DATA(lv_qty)
        ).
      CATCH cx_nr_object_not_found.
*Capture the message from catch
      CATCH cx_number_ranges INTO DATA(lo_error).
*  Populate the message using Failed and Reported
        LOOP AT lt_entities INTO DATA(ls_entity).
**** We will pass failed key field
          APPEND VALUE #( %cid = ls_entity-%cid
                           %key = ls_entity-%key  )
                           TO failed-zi_travel_nk_m.
**** We will pass failed message
          APPEND VALUE #( %cid = ls_entity-%cid
                           %key = ls_entity-%key
                           %msg = lo_error  )
                           TO reported-zi_travel_nk_m.
*                           TO mapp-yi_travel_tech_m.3


        ENDLOOP.
        EXIT.
    ENDTRY.

    ASSERT lv_qty = lines( lt_entities ).

    DATA: lt_travel_tech_m TYPE TABLE FOR MAPPED EARLY yi_travel_tech_m,
          ls_travel_tech_m LIKE LINE OF lt_travel_tech_m.
    DATA lv_current_num(8) TYPE p DECIMALS 0.
*    DATA(lv_current_num) = lv_latest_num - lv_qty.
    lv_current_num = lv_latest_num - lv_qty.

    LOOP AT lt_entities INTO ls_entity.

      lv_current_num += lv_current_num.

*      ls_travel_tech_m = VALUE #( %cid = ls_entity-%cid
*                           TravelId = lv_current_num ).
*
*      APPEND ls_travel_tech_m TO mapped-yi_travel_tech_m.
*******Write same in one line be above line declaration not required
*DATA: lt_travel_tech_m TYPE TABLE FOR MAPPED EARLY yi_travel_tech_m,
*          ls_travel_tech_m LIKE LINE OF lt_travel_tech_m.

      APPEND VALUE #( %cid = ls_entity-%cid
                       TravelId = lv_current_num  )
                       TO mapped-zi_travel_nk_m.

    ENDLOOP.


  ENDMETHOD.


  METHOD earlynumbering_cba_Booking.
    DATA: lv_max_booking TYPE /dmo/booking_id.

    READ ENTITIES OF zi_travel_nk_m
*** IN LOCAL MODE key useful for fast operation because wont got for auth check again
    IN LOCAL MODE
    ENTITY zi_travel_nk_m BY \_Booking
    FROM CORRESPONDING #( entities )
    LINK DATA(lt_link_data)
    FAILED DATA(lt_failed2).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_group_entity>)
    GROUP BY <fs_group_entity>-TravelId.

      lv_max_booking = REDUCE #( INIT lv_max = CONV /dmo/booking_id( '0' )
                       FOR ls_link IN lt_link_data USING KEY entity
                          WHERE ( source-TravelId = <fs_group_entity>-TravelId )
                          NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_link-target-BookingId
                          THEN ls_link-target-BookingId
                          ELSE lv_max    ) ).

      lv_max_booking = REDUCE #( INIT lv_max = lv_max_booking
                                  FOR ls_entity IN entities USING KEY entity
                                  WHERE ( TravelId = <fs_group_entity>-TravelId )
                                  FOR ls_booking IN ls_entity-%target
                                  NEXT lv_max = COND /dmo/booking_id( WHEN lv_max < ls_booking-Bookingid
                                  THEN ls_booking-Bookingid
                                  ELSE lv_max )

                                    ) .
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<fs_entities>)
      USING KEY entity
      WHERE TravelId = <fs_group_entity>-TravelId.

        LOOP AT <fs_entities>-%target ASSIGNING FIELD-SYMBOL(<fs_booking>).
          APPEND CORRESPONDING #( <fs_booking> ) TO mapped-zi_booking_nk_m ASSIGNING FIELD-SYMBOL(<ls_new_map_book>).
          IF <fs_booking>-BookingId IS INITIAL.
            lv_max_booking += 10.
            <ls_new_map_book>-BookingId = lv_max_booking.
          ENDIF.
        ENDLOOP.

      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.

    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_travel_nk_m
    FIELDS ( TravelId OverallStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    result = VALUE #( FOR ls_travel IN lt_travel
                          ( %tky = ls_travel-%tky
                            %features-%action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A'
                                                                          THEN if_abap_behv=>fc-o-disabled
                                                                     ELSE if_abap_behv=>fc-o-enabled
                                                                   )
                            %features-%action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                                          THEN if_abap_behv=>fc-o-disabled
                                                                     ELSE if_abap_behv=>fc-o-enabled
                                                                   )
                            %features-%assoc-_Booking      = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                                          THEN if_abap_behv=>fc-o-disabled
                                                                     ELSE if_abap_behv=>fc-o-enabled
                                                                   )
                           )
                    ).


  ENDMETHOD.

  METHOD acceptTravel.

    MODIFY ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_travel_nk_m
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                        OverallStatus = 'A' ) )
    REPORTED DATA(lt_travel).

    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_travel_nk_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                   %param = ls_result ) ).

  ENDMETHOD.


  METHOD copyTravel.

    DATA: it_travel       TYPE TABLE FOR CREATE zi_travel_nk_m,
          it_booking_cba  TYPE TABLE FOR CREATE zi_travel_nk_m\_Booking,
          it_booksupp_cbA TYPE TABLE FOR CREATE zi_booking_nk_m\_Bookingsuppl.


    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_without_cid>) WITH KEY %cid = ' '.
    ASSERT <ls_without_cid> IS NOT ASSIGNED.

    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_travel_nk_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel_r)
    FAILED DATA(lt_failed).

    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_travel_nk_m BY \_Booking
    ALL FIELDS WITH CORRESPONDING #( lt_travel_r )
    RESULT DATA(lt_booking_r).

    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_booking_nk_m BY \_Bookingsuppl
    ALL FIELDS WITH CORRESPONDING #( lt_booking_r )
    RESULT DATA(lt_booksupp_r).

    LOOP AT lt_travel_r ASSIGNING FIELD-SYMBOL(<ls_travel_r>).

*    APPEND INITIAL LINE TO it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
*    <ls_travel>-%cid = keys[ KEY entity TravelId = <ls_travel_r>-TravelId ]-%cid.
*    <ls_travel>-%data = CORRESPONDING #( <ls_travel_r> EXCEPT TravelId ).
*    Same statement in shoter form
      APPEND VALUE #( %cid = keys[ KEY entity TravelId = <ls_travel_r>-TravelId  ]-%cid
                      %data = CORRESPONDING #( <ls_travel_r> EXCEPT TravelId ) )
                      TO it_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      <ls_travel>-BeginDate = cl_abap_context_info=>get_system_date(  ).
      <ls_travel>-EndDate = cl_abap_context_info=>get_system_date(  ) + 30.
      <ls_travel>-OverallStatus = 'O'.
****** Fill CID reference
      APPEND VALUE #( %cid_ref = <ls_travel>-%cid )
      TO it_booking_cba ASSIGNING FIELD-SYMBOL(<ls_booking>).

      LOOP AT lt_booking_r ASSIGNING FIELD-SYMBOL(<ls_booking_r>)
                            USING KEY entity
                            WHERE TravelId = <ls_travel_r>-TravelId.

        APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId
                        %data = CORRESPONDING #( <ls_booking_r> EXCEPT TravelId ) )
                        TO <ls_booking>-%target ASSIGNING FIELD-SYMBOL(<ls_booking_n>).
        <ls_booking_n>-BookingStatus = 'O'.

        APPEND VALUE #( %cid_ref = <ls_booking_n>-%cid )
        TO it_booksupp_cba ASSIGNING FIELD-SYMBOL(<ls_booksupp>).

        LOOP AT lt_booksupp_r ASSIGNING FIELD-SYMBOL(<ls_booksupp_r>)
                                 USING KEY entity
                                 WHERE TravelId = <ls_travel_r>-TravelId AND
                                       BookingId = <ls_booking_r>-BookingId.

          APPEND VALUE #( %cid = <ls_travel>-%cid && <ls_booking_r>-BookingId && <ls_booksupp_r>-BookingSupplementId
                          %data = CORRESPONDING #( <ls_booksupp_r> EXCEPT TravelId   BookingId ) )
                          TO <ls_booksupp>-%target.

        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_travel_nk_m
    CREATE FIELDS ( AgencyId CustomerId BeginDate EndDate BookingFee TotalPrice CurrencyCode OverallStatus Description )
    WITH it_travel
    ENTITY zi_travel_nk_m
    CREATE BY \_Booking
    FIELDS ( BookingId BookingDate CustomerId CarrierId ConnectionId FlightDate FlightPrice CurrencyCode BookingStatus  )
    WITH it_booking_cba
    ENTITY zi_booking_nk_m
    CREATE BY \_Bookingsuppl
    FIELDS ( BookingSupplementId SupplementId Price CurrencyCode )
    WITH it_booksupp_cba
    MAPPED DATA(it_mapped).

    mapped-zi_travel_nk_m = it_mapped-zi_travel_nk_m.

  ENDMETHOD.

  METHOD rejectTravel.
    MODIFY ENTITIES OF zi_travel_nk_m IN LOCAL MODE
     ENTITY zi_travel_nk_m
     UPDATE FIELDS ( OverallStatus )
     WITH VALUE #( FOR ls_keys IN keys ( %tky = ls_keys-%tky
                                         OverallStatus = 'X' ) )
     REPORTED DATA(lt_travel).

    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_travel_nk_m
    ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result).

    result = VALUE #( FOR ls_result IN lt_result ( %tky = ls_result-%tky
                                                   %param = ls_result ) ).
  ENDMETHOD.



  METHOD validateBookingfee.
  ENDMETHOD.

  METHOD validateCurencyCode.
  ENDMETHOD.

  METHOD validateDates.

    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
                ENTITY zi_travel_nk_m
                  FIELDS ( BeginDate EndDate )
                  WITH CORRESPONDING #( keys )
                RESULT DATA(lt_travels).

    LOOP AT lt_travels INTO DATA(travel).

      IF travel-EndDate < travel-BeginDate.  "end_date before begin_date

        APPEND VALUE #( %tky = travel-%tky ) TO failed-zi_travel_nk_m.

        APPEND VALUE #( %tky = travel-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                   textid     = /dmo/cm_flight_messages=>begin_date_bef_end_date
                                   severity   = if_abap_behv_message=>severity-error
                                   begin_date = travel-BeginDate
                                   end_date   = travel-EndDate
                                   travel_id  = travel-TravelId )
                        %element-BeginDate   = if_abap_behv=>mk-on
                        %element-EndDate     = if_abap_behv=>mk-on
                     ) TO reported-zi_travel_nk_m.

      ELSEIF travel-BeginDate < cl_abap_context_info=>get_system_date( ).  "begin_date must be in the future

        APPEND VALUE #( %tky        = travel-%tky ) TO failed-zi_travel_nk_m.

        APPEND VALUE #( %tky = travel-%tky
                        %msg = NEW /dmo/cm_flight_messages(
                                    textid   = /dmo/cm_flight_messages=>begin_date_on_or_bef_sysdate
                                    severity = if_abap_behv_message=>severity-error )
                        %element-BeginDate  = if_abap_behv=>mk-on
                        %element-EndDate    = if_abap_behv=>mk-on
                      ) TO reported-zi_travel_nk_m.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateStatus.
    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_travel_nk_m
      FIELDS ( OverallStatus )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travels).

    LOOP AT lt_travels INTO DATA(ls_travel).
      CASE ls_travel-OverallStatus.
        WHEN 'O'.  " Open
        WHEN 'X'.  " Cancelled
        WHEN 'A'.  " Accepted

        WHEN OTHERS.
          APPEND VALUE #( %tky = ls_travel-%tky ) TO failed-zi_travel_nk_m.

          APPEND VALUE #( %tky = ls_travel-%tky
                          %msg = NEW /dmo/cm_flight_messages(
                                     textid = /dmo/cm_flight_messages=>status_invalid
                                     severity = if_abap_behv_message=>severity-error
                                     status = ls_travel-OverallStatus )
                          %element-OverallStatus = if_abap_behv=>mk-on
                        ) TO reported-zi_travel_nk_m.
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.

  METHOD recalcTotPrice.

    TYPES : BEGIN OF ty_total,
              price TYPE /dmo/total_price,
              curr  TYPE /dmo/currency_code,
            END OF ty_total .
    DATA: lt_total      TYPE TABLE OF ty_total,
          lv_conv_price TYPE ty_total-price.
*☺

    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
     ENTITY zi_travel_nk_m
     FIELDS ( BookingFee CurrencyCode )
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_travel).

    DELETE lt_travel WHERE CurrencyCode IS INITIAL.

    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
     ENTITY zi_travel_nk_m BY \_Booking
     FIELDS ( FlightPrice CurrencyCode )
     WITH CORRESPONDING #( lt_travel )
     RESULT DATA(lt_ba_booking).

    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
     ENTITY zi_booking_nk_m BY \_Bookingsuppl
     FIELDS ( Price CurrencyCode )
     WITH CORRESPONDING #( lt_ba_booking )
     RESULT DATA(lt_ba_booksuppl).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      lt_total =  VALUE #( ( price = <ls_travel>-BookingFee curr = <ls_travel>-CurrencyCode ) ).

      LOOP AT lt_ba_booking ASSIGNING FIELD-SYMBOL(<ls_booking>)
                                 USING KEY entity
                                  WHERE TravelId = <ls_travel>-TravelId
                                  AND CurrencyCode IS NOT INITIAL.

        APPEND VALUE #( price = <ls_booking>-FlightPrice curr = <ls_booking>-CurrencyCode )
           TO lt_total.

        LOOP AT lt_ba_booksuppl ASSIGNING FIELD-SYMBOL(<ls_booksuppl>)
                                          USING KEY entity
                                          WHERE TravelId = <ls_booking>-TravelId
                                           AND  BookingId = <ls_booking>-BookingId
                                            AND CurrencyCode IS NOT INITIAL..
          APPEND VALUE #( price = <ls_booksuppl>-Price curr = <ls_booksuppl>-CurrencyCode )
           TO lt_total.
        ENDLOOP.
      ENDLOOP.

      LOOP AT lt_total ASSIGNING FIELD-SYMBOL(<ls_total>).

        IF <ls_total>-curr = <ls_travel>-CurrencyCode.
          lv_conv_price = <ls_total>-price.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = <ls_total>-price
              iv_currency_code_source = <ls_total>-curr
              iv_currency_code_target = <ls_travel>-CurrencyCode
              iv_exchange_rate_date   =  cl_abap_context_info=>get_system_date( )
            IMPORTING
              ev_amount               = lv_conv_price
          ).

        ENDIF.

        <ls_travel>-TotalPrice =  <ls_travel>-TotalPrice + lv_conv_price.
      ENDLOOP.


    ENDLOOP.

    MODIFY ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_travel_nk_m
    UPDATE FIELDS ( TotalPrice )
    WITH CORRESPONDING #( lt_travel ).

  ENDMETHOD.

  METHOD calculateTotalPrice.

    MODIFY ENTITIES OF zi_travel_nk_m IN LOCAL MODE
       ENTITY zi_travel_nk_m
       EXECUTE recalcTotPrice
       FROM CORRESPONDING #( keys ).


  ENDMETHOD.

  METHOD get_global_features.
  ENDMETHOD.

ENDCLASS.
