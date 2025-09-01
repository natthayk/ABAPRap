CLASS lhc_zi_booksupp_nk_m DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS calculateTotalPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZI_BOOKSUPP_NK_M~calculateTotalPrice.

ENDCLASS.

CLASS lhc_zi_booksupp_nk_m IMPLEMENTATION.

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
