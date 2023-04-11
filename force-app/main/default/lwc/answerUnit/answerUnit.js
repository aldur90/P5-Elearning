import { LightningElement, api } from 'lwc';
const SELECTED = 'tile-wrapper selected custom-box slds-box slds-p-around_medium';
const UNSELECTED = 'tile-wrapper custom-box slds-box slds-p-around_medium';

export default class AnswerUnit extends LightningElement {
    @api answer;
    @api question;
    @api optionSelected;
    optionId;

    handleClick() {
        let answerId = this.answer.Id;
        let questionId = this.question.Id
        console.log(this.answer.Name);
        const choice = new CustomEvent("optionselect", {
            detail: {
                questionId,
                answerId

            }
        })
        this.dispatchEvent(choice);
    }

    get tileClass() {
        if (this.optionSelected.includes(this.answer.Id)) {
            return SELECTED
        } else {
            return UNSELECTED
        }
    }




}