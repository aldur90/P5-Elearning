import { LightningElement, api, wire, track } from 'lwc';
import getUnitWrapper from '@salesforce/apex/UnitService.getUnit';
import registerUserAnswer from '@salesforce/apex/JSController.registerUserAnswer';

export default class UnitContent extends LightningElement {
    @api recordId
    unit;
    questions;
    name;
    points;
    time;
	isCompletedUnit;

    @wire(getUnitWrapper, {unitId:'$recordId'})
    unitdata(Result){
        const { data, error } = Result;

        if(data){
            this.unit = data.unit;
            this.questions = data.questions;
            this.points = data.unit.Points__c;
            this.time = data.unit.Time_Estimate__c;

        }   else if (error) {
            this.error = error;
            console.log(error);
        }
    }

    @track 
    optionSelected = [];
    @api
    optionSelectedjson = {};

    answerSelected(event) {

        console.log(JSON.stringify(event.detail));
        console.log("QuestionId " + event.detail.questionId);
        console.log("OptionId " + event.detail.answerId);
        this.optionSelectedjson[event.detail.questionId] = event.detail.answerId;
        console.log(this.optionSelectedjson);
             
        this.optionSelected = Object.values(this.optionSelectedjson);
        console.log(this.optionSelected);    
        console.log(Object.values(this.optionSelectedjson));     
    }



    handleSubmit(event) {
		event.preventDefault();
		let optionUnits = this.template.querySelectorAll('c-option-unit');
		let _jsonAnswer = {};

		for (const optionUnit of optionUnits) {
			_jsonAnswer = {... _jsonAnswer, ...optionUnit.selectedOption};
		}

		_jsonAnswer = JSON.stringify(_jsonAnswer);
		console.log(_jsonAnswer);

        registerUserAnswer({ unitId: this.recordId, jsonAnswer: _jsonAnswer})
		.then((result) => {
			console.log('succesfully');
			this.isCompletedUnit = result
		})
        .catch((error)=>{
			console.log('has an error');
            console.log(error)
        });
		console.log(this.isCompletedUnit);
    }

}