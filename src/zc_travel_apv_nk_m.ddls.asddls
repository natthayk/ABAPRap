@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Projection View - Travel for Approver'

@UI.headerInfo: {
    typeName: 'Travel',
    typeNamePlural: 'Travels',
    title: {
        type: #STANDARD,
        label: 'Travel',
        value: 'TravelId'
    }
}
define root view entity ZC_TRAVEL_APV_NK_M
  provider contract transactional_query
  as projection on zI_travel_nk_m
{
      @UI.facet: [{
          id: 'Travel',
          purpose: #STANDARD,
          position: 10 ,
          label: 'Travel',
          type: #IDENTIFICATION_REFERENCE
      }
      ,
      {
          id: 'Booking',
          purpose: #STANDARD,
          position: 20 ,
          label: 'Booking',
          type: #LINEITEM_REFERENCE,
          targetElement: '_Booking'
      }
      ]
      @UI.lineItem: [{ position: 10 , importance: #HIGH } ]
      @UI.identification: [{ position: 10 }]
      @Search.defaultSearchElement: true
  key TravelId,
      @UI: { lineItem: [{ position: 20 }],
         selectionField: [{ position: 20 }],
         identification: [{ position: 20 }]
       }
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Agency',
          element: 'AgencyID'
      } }]
      @ObjectModel.text.element: [ 'AgencyName' ]
      AgencyId,
      _Agency.Name       as AgencyName,

      @UI: { lineItem: [{ position: 30 }],
       selectionField: [{ position: 30 }],
        identification: [{ position: 30 }]
      }
      @Search.defaultSearchElement: true
      @Consumption.valueHelpDefinition: [{ entity: {
          name: '/DMO/I_Customer',
          element: 'CustomerID'
      } }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      CustomerId,
      _Customer.LastName as CustomerName,
      
      
      @UI.lineItem: [{ position: 40 }]
      @UI.identification: [{ position: 40 }]
      BeginDate,
      
      @UI.lineItem: [{ position: 50 }]
      @UI.identification: [{ position: 50 }]
      EndDate,
      
      @UI.lineItem: [{ position: 60 , importance: #MEDIUM}]
      @UI.identification: [{ position: 60 }]
      BookingFee,
      
      @UI.lineItem: [{ position: 61 , importance: #MEDIUM}]
      @UI.identification: [{ position: 61 }]
      TotalPrice,
      
      @Consumption.valueHelpDefinition: [{ entity: {
      name: 'I_Currency',
      element: 'Currency' } }]
      CurrencyCode,
      
      @UI.lineItem: [{ position: 65 , importance: #MEDIUM}]
      @UI.identification: [{ position: 65 }]
      Description,
      
      @UI: { lineItem: [{ position: 70 , importance: #HIGH },
                        {type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'Accept Travel'},
                        {type: #FOR_ACTION, dataAction: 'rejectTravel', label: 'Reject Travel'} ],
       selectionField: [{ position: 40 }],
       identification: [{ position: 70 },
                        {type: #FOR_ACTION, dataAction: 'acceptTravel', label: 'Accept Travel'},
                        {type: #FOR_ACTION, dataAction: 'rejectTravel', label: 'Reject Travel'} ],
       textArrangement: #TEXT_ONLY
      }
      @Search.defaultSearchElement: true
      @EndUserText.label: 'Overall Status'
      @Consumption.valueHelpDefinition: [{ entity: {
       name: '/DMO/I_Overall_Status_VH',
       element: 'OverallStatus'
      } }]
      @ObjectModel.text.element: [ 'OverallStatusText' ]
      OverallStatus,
      _Status._Text.Text as OverallStatusText : localized,
      
      @UI.hidden: true
      CreatedBy,
      
      @UI.hidden: true
      CreatedAt,
      
      @UI.hidden: true
      LastChangedBy,
      
      @UI.hidden: true
      LastChangedAt,
      /* Associations */
      _Agency,
      _Booking : redirected to composition child ZC_BOOKING_APV_NK_M,
      _Currency,
      _Customer,
      _Status
}
