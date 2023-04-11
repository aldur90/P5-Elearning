import { api, LightningElement } from 'lwc';

export default class ModuleView extends LightningElement {
    @api name;
    @api time;
    @api description;
    @api points;
    @api module;
    @api checkmodule;
    @api checkunit;

    get successModule() {

        return this.checkmodule.includes(this.module.Id);
    }
}