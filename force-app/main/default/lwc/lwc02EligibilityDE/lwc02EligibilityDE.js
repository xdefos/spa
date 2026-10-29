import { LightningElement, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { subscribe, publish, unsubscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getEligibilityDE from "@salesforce/apex/CMP02_EligibilityDEController.getEligibilityDE";
import sendEmail from "@salesforce/apex/CMP02_EligibilityDEController.sendEmail";
import EligibilityActionEvent from '@salesforce/messageChannel/EligibilityActionEvent__c';

const ENQUETE_FIELDS = [
    'Enquete__c.Geolocation__Latitude__s',
    'Enquete__c.Geolocation__Longitude__s'
];

export default class Lwc02EligibilityDE extends LightningElement {
    @api recordId;
    record;
    gridData;
    subscription;
    display;
    selectedRows=[];
    loaded=false;
    maxDistanceDE;
    maxDistanceE;

    @wire(getRecord, { recordId: '$recordId', fields: ENQUETE_FIELDS })
    wiredEnquete(value){
        const { data, error } = value;
        if(data) {
            console.log(JSON.stringify(data));
            this.record = data;
        } 
    }

    @wire(MessageContext)
    messageContext;

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

    get isSubscribed(){
        return this.subscribe != null;
    }

    handleMessage(message) {
        console.log('mess:'+JSON.stringify(message));
        if(message.fireEligibilityAction){
            this.display = message.fireEligibilityAction;
            if(this.display == true && this.loaded == false){
                this.run();
            }
        }
    }

    handleMaxDistanceDEChange(event){
        console.log(event.target.value);
        this.maxDistanceDE = event.target.value;
    }
    handleMaxDistanceEChange(event){
        console.log(event.target.value);
        this.maxDistanceE = event.target.value;
    }

    connectedCallback() {
        this.maxDistanceDE = 50;
        this.maxDistanceE = 20;
        this.subscribeToMessageChannel();
    }

    run(){
        this.loaded = false;
        console.log("call APEX");
        console.log(this.maxDistanceDE);
        console.log(this.maxDistanceE);
        getEligibilityDE({ recordId: this.recordId, maxDistanceDE: this.maxDistanceDE, maxDistanceE: this.maxDistanceE }).then(result => {
            console.log('#result:'+JSON.stringify(result));
            let dataArray = new Array();
            for(let item of result){
                dataArray.push(this.formatData(item));
            }
            // this.gridColumns = result.columns;
            this.gridData = dataArray;
            this.loaded = true;
        }).catch(error => {
            console.log(error);
        });
    }

    formatRow(data){
        let formattedData = {
            'actionLabel':null,
            'actionTitle':null,
            'actionVariant':null,
            'emailVariant': 'brand',
            'mapVariant': 'brand',
            'Id': data.record.Id, 
            'Name': data.record.Name,
            'Enquetes': data.enquetes,
            'Distance': data.distance.text,
            'EnquetesEnCours': data.record.EnquetesEnCours__c != null ? data.record.EnquetesEnCours__c : 0,
            'EnquetesAnnuel': data.record.EnquetesAnnuel__c != null ? data.record.EnquetesAnnuel__c : 0,
            'EnquetesEnCoursZone':0
        };
        if(data.type == 'Enquete__c'){
            formattedData.disableEmailButton = true; 
            formattedData.mapVariant = 'border';
            formattedData.emailVariant = 'bare';
        }

        if(data.children != null){
            formattedData.EnquetesEnCoursZone = data.children.length;
        }
        return formattedData;
    }

    formatData(data){
        let formattedData = this.formatRow(data);
        if(data.children != null){
            let allChildren = new Array();
            for(let child of data.children){
                allChildren.push(this.formatRow(child));
            }
            formattedData["_children"] = allChildren;
        }
        return formattedData;
    }

    handleAction(event){
        this.loading = true;

        if(event.detail.action.title == 'Map'){
            let recordList = new Array();
            recordList.push(event.detail.row.Id);
            if(event.detail.row.hasChildren){
                for(let de of this.gridData){
                    if(de.Id == event.detail.row.Id && de._children != null){
                        for(let child of de._children){
                            recordList.push(child.Id);
                        }
                    }
                }
            }
            
            const payload = { type: 'DisplayOnMap', recordIds: recordList };

            publish(this.messageContext, EligibilityActionEvent, payload);
        }

        if(event.detail.action.title == 'Email'){
            sendEmail({ enqueteId: this.recordId, deId: event.detail.row.Id }).then(result => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Email sent!',
                        message: 'Email sent successfully to ' + event.detail.row.Name,
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
                this.loading = false;
            }).catch(error => {
                new ShowToastEvent({
                    title: 'Error',
                    message: error.message,
                    variant: 'error',
                    mode: 'dismissable'
                })
                console.log(error);
            });
        }
    }

    gridColumns = [
        {
            type: 'text',
            fieldName: 'Name',
            label: 'Nom',
        },
        {
            type: 'text',
            fieldName: 'Distance',
            label: 'Distance',
            initialWidth: 93
        },
        {
            type: 'number',
            fieldName: 'EnquetesEnCoursZone',
            label: 'Dans la zone',
            initialWidth: 120
        },
        {
            type: 'number',
            fieldName: 'EnquetesEnCours',
            label: 'En cours',
            initialWidth: 95
        },
        {
            type: 'number',
            fieldName: 'EnquetesAnnuel',
            label: 'Depuis 1 an',
            initialWidth: 115
        },
        {
            type: 'button-icon',
            fieldName: 'EmailAction',
            label: '',
            initialWidth: 40,
            typeAttributes: {
                label: 'Email',
                title: 'Email',
                variant: { fieldName: 'emailVariant' },
                disabled: { fieldName: 'disableEmailButton' },
                iconName: 'utility:email'
            }
        },
        {
            type: 'button-icon',
            fieldName: 'MapAction',
            label: '',
            initialWidth: 40,
            typeAttributes: {
                label: 'Map',
                title: 'Map',
                variant: { fieldName: 'mapVariant' },
                iconName: 'utility:location'
            }
        }
    ];
}