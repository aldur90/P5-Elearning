import { api, LightningElement, wire } from 'lwc';
import getTrail from '@salesforce/apex/TrailWrapper.getTrailWrapper';

export default class TrailView extends LightningElement {

    @api recordId;
    name;
    time;
    description;
    points;
    progress;
    error = undefined;
    modules;
    checkmodule;
    checkunit;

    @wire(getTrail, { trailId: '$recordId' })
    trail(Result) {
        const { data, error } = Result;
        if (data) {
            console.log(data);
            this.name = data.trail.Name;
            this.time = data.trail.Time_Estimated__c;
            this.description = data.trail.Description__c;
            this.points = data.trail.Points__c;
            // Hay que crear algun campo en trail que cuente la cantidad total de unidades
            this.progress = 0;
            this.modules = data.modules;
            this.checkmodule = data.passedModuleIds;
            this.checkunit = data.passedUnitIds;
        } else if (error) {
            this.trailWrapper = undefined;
            this.error = error;
        }
    }
}