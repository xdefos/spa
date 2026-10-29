import { LightningElement,api, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import EligibilityActionEvent from '@salesforce/messageChannel/EligibilityActionEvent__c';

export default class Lwc03EligibilityAction extends LightningElement {

    @wire(MessageContext)
    messageContext;

    @api invoke() {
        const payload = {fireEligibilityAction: true};
        publish(this.messageContext, EligibilityActionEvent, payload);
    } 
}