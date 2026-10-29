({
    init: function (cmp, event, helper) {

        cmp.set('v.zoomLevel', 9);
        //cmp.set('v.markersTitle', 'Marker locations');
        cmp.set('v.showFooter', false);

        var getMarker = cmp.get("c.getMarker");
        getMarker.setParams({
            sObjectId: cmp.get("v.recordId")
        });
        getMarker.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var obj =response.getReturnValue() ;
                console.log('*** JSON.stringify(obj): ' + JSON.stringify(obj));
                cmp.set('v.center',obj);
                cmp.set('v.mapMarkers',obj);
                cmp.set('v.zoomLevel', 9);
                cmp.set('v.markersTitle', 'Salesforce locations');
                cmp.set('v.showFooter', true);
            }
        });
        $A.enqueueAction(getMarker);  
    }
})