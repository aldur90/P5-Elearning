import { LightningElement, api } from 'lwc';

export default class OptionUnit extends LightningElement {

    @api questionId;
    @api options;
    @api selectedOption;
    _radioOptions = [];
    value;

    get radioOptions() {
        if (this.options) {
            this.options.forEach(option => {
                this._radioOptions.push({label: option.Description__c, value: option.Id})
            });
            this.value = this._radioOptions[0].value;
            this.selectedOption = {[this.questionId]: this.value};
        }
        return this._radioOptions;
    }

    handleChange(event) {
        let optionId = event.detail.value;
        this.selectedOption = { [this.questionId]: optionId };
    }
}