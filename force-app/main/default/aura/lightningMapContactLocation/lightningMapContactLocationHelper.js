({
    loadMap : function(component,event,helper,contacts) {
        var mapsArray = [];
        for(let index=0; index < contacts.length; index++){
            
            var Mobj = {
                location: {
                    Street: contacts[index].MailingStreet,
                    City: contacts[index].MailingCity,
                    PostalCode: contacts[index].MailingPostalCode,
                    State: contacts[index].MailingState,
                    Country: contacts[index].MailingCountry
                },
                icon: 'standard:contact',
                title: contacts[index].Name,
                description: contacts[index].Phone
            }
            mapsArray.push(Mobj);
        }
        component.set('v.mapMarkers', mapsArray);
        component.set('v.centerObj', {
            location: {
                City: 'Noida'
            }
        });
        component.set('v.zoomLevel', 12);
        component.set('v.markersTitle', 'Contacts locations');
        component.set('v.showFooter', true);
    }
})