CLASS lhc_zi_booking_nk_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE zi_booking_nk_m\_Bookingsuppl.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ZI_BOOKING_NK_M RESULT result.
    METHODS calculatetotalprice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR zi_booking_nk_m~calculatetotalprice.

ENDCLASS.

CLASS lhc_zi_booking_nk_m IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.

    DATA: max_booking_suppl_id TYPE /dmo/booking_supplement_id.

    READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_booking_nk_m BY \_Bookingsuppl
    FROM CORRESPONDING #( entities )
    LINK DATA(booking_supplements).

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking_group>)
    GROUP BY <booking_group>-%tky.
*    %tky used for draft scenario instead of using %key

      max_booking_suppl_id = REDUCE #( INIT max = CONV /dmo/booking_supplement_id( '0' )
                                FOR booksuppl IN booking_supplements USING KEY entity
                                WHERE ( source-TravelId = <booking_group>-TravelId AND
                                        source-BookingId = <booking_group>-BookingId )
                               NEXT max = COND /dmo/booking_supplement_id( WHEN booksuppl-target-BookingSupplementId > max
                                                                           THEN booksuppl-target-BookingSupplementId
                                                                           ELSE max )
                                         ).

      max_booking_suppl_id = REDUCE #( INIT max = max_booking_suppl_id
                                    FOR entity IN entities USING KEY entity
                                    WHERE ( TravelId = <booking_group>-TravelId AND
                                            BookingId = <booking_group>-BookingId )

                                    FOR target IN entity-%target
                                    NEXT max = COND /dmo/booking_supplement_id( WHEN target-BookingSupplementId > max
                                                                                THEN target-BookingSupplementId
                                                                                ELSE max )

                                     ).

      LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>) USING KEY entity
      WHERE TravelId = <booking_group>-TravelId AND
            BookingId = <booking_group>-BookingId.

        LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<booksuppl>).
          APPEND CORRESPONDING #( <booksuppl> ) TO mapped-zi_booksupp_nk_m ASSIGNING FIELD-SYMBOL(<mapped_booksuppl>).
          IF <booksuppl>-BookingSupplementId IS INITIAL.
            max_booking_suppl_id += 1.
            <mapped_booksuppl>-BookingSupplementId = max_booking_suppl_id.
          ENDIF.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.

   READ ENTITIES OF zi_travel_nk_m IN LOCAL MODE
    ENTITY zi_travel_nk_m BY \_Booking
    FIELDS ( TravelId BookingStatus )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_booking).

    result = VALUE #( for ls_booking IN lt_booking
                          ( %tky = ls_booking-%tky
                            %features-%assoc-_Bookingsuppl = COND #( WHEN ls_booking-BookingStatus = 'X'
                                                                          THEN if_abap_behv=>fc-o-disabled
                                                                     ELSE if_abap_behv=>fc-o-enabled
                                                                   )
                           )
                    ).


  ENDMETHOD.

  METHOD calculateTotalPrice.

    DATA: it_travel_key TYPE STANDARD TABLE OF zi_travel_nk_m WITH UNIQUE HASHED KEY key COMPONENTS TravelId.

    it_travel_key = CORRESPONDING #( keys DISCARDING DUPLICATES MAPPING TravelId = TravelId ).

     MODIFY ENTITIES OF zi_travel_nk_m IN LOCAL MODE
     ENTITY zi_travel_nk_m
     EXECUTE recalcTotPrice
     FROM CORRESPONDING #( it_travel_key ).

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
