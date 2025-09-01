@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View - Booking for Approver'

@UI.headerInfo: {
    typeName: 'Booking',
    typeNamePlural: 'Bookings',
    title: {
        type: #STANDARD,
        label: 'Booking',
        value: 'BookingId'
    }
}
define view entity ZC_BOOKING_APV_NK_M as projection on ZI_BOOKING_NK_M
{
     @UI.facet: [{
          id: 'Booking',
          purpose: #STANDARD,
          position: 10 ,
          label: 'Booking',
          type: #IDENTIFICATION_REFERENCE
      }
      ,
      {
          id: 'BookingSuppl',
          purpose: #STANDARD,
          position: 20 ,
          label: 'BookingSuppl',
          type: #LINEITEM_REFERENCE,
          targetElement: '_Bookingsuppl'
      }

      ]
      @Search.defaultSearchElement: true
  key TravelId,
      @UI.lineItem: [{ position: 10, importance: #HIGH }]
      @UI.identification: [{ position: 10 }]
      @Search.defaultSearchElement: true
  key BookingId,
      @UI.lineItem: [{ position: 20, importance: #HIGH }]
      @UI.identification: [{ position: 20 }]
      BookingDate,
      @UI.lineItem: [{ position: 30,importance: #HIGH }]
      @UI.identification: [{ position: 30 }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _Customer.LastName         as CustomerName,
      
      @UI.lineItem: [{ position: 40,importance: #HIGH }]
      @UI.identification: [{ position: 40 }]
      @ObjectModel.text.element: [ 'CarrierName' ]
      CarrierId,
      _Carrier.Name              as CarrierName,
      
       @UI.lineItem: [{ position: 50,importance: #HIGH }]
      @UI.identification: [{ position: 50 }]
      ConnectionId,
      
      @UI.lineItem: [{ position: 60,importance: #HIGH }]
      @UI.identification: [{ position: 60 }]
      FlightDate,
      
      @UI.lineItem: [{ position: 70,importance: #HIGH }]
      @UI.identification: [{ position: 70 }]
      FlightPrice,
      CurrencyCode,
      
      @UI.lineItem: [{ position: 80, importance: #HIGH }]
      @UI.identification: [{ position: 80 }]
      @UI.textArrangement: #TEXT_ONLY
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Booking_Status_VH',
          element: 'BookingStatus'
      } }]
      @ObjectModel.text.element: [ 'CarrierName' ]
      BookingStatus,
      
      @UI.hidden: true
      _Booking_Status._Text.Text as BokkingStatusText : localized,
      
      @UI.hidden: true
      LastChangedAt,
      
      /* Associations */
      _Bookingsuppl : redirected to composition child ZC_BOOKSUPP_APV_NK_M,
      _Booking_Status,
      _Carrier,
      _Connection,
      _Customer,
      _Travel  : redirected to parent ZC_TRAVEL_APV_NK_M
}
