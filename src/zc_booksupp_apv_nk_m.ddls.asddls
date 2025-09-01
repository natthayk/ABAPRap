@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View - Booking Suppl for Appr'

define view entity ZC_BOOKSUPP_APV_NK_M
  as projection on ZI_BOOKSUPP_NK_M
{
      @UI.facet: [{
      id: 'BookingSuppl',
      purpose: #STANDARD,
      position: 10 ,
      label: 'BookingSuppl',
      type: #IDENTIFICATION_REFERENCE
      }
      ]
      @Search.defaultSearchElement: true
  key TravelId,

      @UI.lineItem: [{ position: 10, label: 'Booking ID' } ]
      @UI.identification: [{ position: 10 }]
      @Search.defaultSearchElement: true
  key BookingId,

      @UI.lineItem: [{ position: 20, label: 'Booking Suppl ID' } ]
      @UI.identification: [{ position: 20 }]
  key BookingSupplementId,

      @UI.lineItem: [{ position: 30, label: 'Supp ID' }]
      @UI.identification: [{ position: 30 }]
      @Consumption.valueHelpDefinition: [{ entity: {
        name: '/DMO/I_SUPPLEMENT',
        element: 'SupplementID'
      },
      additionalBinding: [{ element: 'SupplementID' ,
                                localElement: 'SupplementId'},
                              { element: 'Price' ,
                                localElement: 'Price'},
                              { element: 'CurrencyCode' ,
                                localElement: 'CurrencyCode'}
                         ]


       }]
      SupplementId,
      
      @UI.identification: [{ position: 40 }]
      Price,
      CurrencyCode,
      
      @UI.identification: [{ position: 50 }]
      LastChangedAt,
      
      
      /* Associations */
      _Booking: redirected to parent ZC_BOOKING_APV_NK_M,
      _Supplement,
      _SupplementText,
      _Travel: redirected to ZC_TRAVEL_APV_NK_M
}
