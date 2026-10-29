import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getMarker from "@salesforce/apex/CMP01_GoogleMapController.getMarker";
import getMarkers from "@salesforce/apex/CMP01_GoogleMapController.getMarkers";
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import EligibilityActionEvent from '@salesforce/messageChannel/EligibilityActionEvent__c';


export default class Lwc01GoogleMap extends LightningElement {
    subscription = null;
    affichetoi = false;

    @api recordId;
    enqueteMarker;
    mapMarkers;
    markersTitle='Google Map';
    zoomLevel=9;
    showFooter=false;
    center;
    
    @wire(MessageContext)
    messageContext;

    get isSubscribed(){
        return this.subscribe != null;
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                EligibilityActionEvent,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message) {
        if(message.type == 'DisplayOnMap'){
            getMarkers({ recordIds: message.recordIds }).then(result =>{
                let newMarkers = new Array();
                newMarkers.push(this.enqueteMarker);
                newMarkers = newMarkers.concat(result.map(this.formatMarker));
                this.mapMarkers = newMarkers;
                console.log(JSON.stringify(newMarkers));
                this.zoomLevel = null;
            }).catch(error => {
                console.log(error);
            });
        }
    }

    formatMarker(marker){
        let newMarker = {};
        newMarker = Object.assign(newMarker, marker);
        if(marker.sObjectName == 'DelegueEnqueteur__c'){
            newMarker.mapIcon = {
                url: "https://mt.googleapis.com/vt/icon/name=icons/onion/SHARED-mymaps-container-bg_4x.png,icons/onion/SHARED-mymaps-container_4x.png,icons/onion/1733-wc-unisex_4x.png&highlight=ff000000,01D758&scale=0.8"
            };
        }
        if(newMarker.sObjectName == 'Enquete__c'){
            newMarker.mapIcon = {
                url: "https://mt.googleapis.com/vt/icon/name=icons/onion/SHARED-mymaps-container-bg_4x.png,icons/onion/SHARED-mymaps-container_4x.png,icons/onion/1506-animal-head_4x.png&highlight=ff000000,0288D1&scale=0.8"
            };
        }
        return newMarker;
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    @wire(getMarker, { sObjectId: '$recordId' })
    wiredMarker({ error, data }) {
        if (data) {
            console.log(JSON.stringify(data));
            this.mapMarkers = data;
            this.center = data[0];
            this.enqueteMarker = data[0];
            this.markersTitle = 'Salesforce locations';
        } else if (error) {
            this.showNotification("Error " + error.status, error.body.message, "error");
        }
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }


    // mp.set('v.zoomLevel', 9);
    //     //cmp.set('v.markersTitle', 'Marker locations');
    //     cmp.set('v.showFooter', false);

    //     var getMarker = cmp.get("c.getMarker");
    //     getMarker.setParams({
    //         sObjectId: cmp.get("v.recordId")
    //     });
    //     getMarker.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state == "SUCCESS") {
    //             var obj =response.getReturnValue() ;
    //             console.log('*** JSON.stringify(obj): ' + JSON.stringify(obj));
    //             cmp.set('v.center',obj);
    //             cmp.set('v.mapMarkers',obj);
    //             cmp.set('v.zoomLevel', 9);
    //             cmp.set('v.markersTitle', 'Salesforce locations');
    //             cmp.set('v.showFooter', true);
    //         }
    //     });
    //     $A.enqueueAction(getMarker);  
}