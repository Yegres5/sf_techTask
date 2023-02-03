/**
 * Created by evgeny on 31.01.2023.
 */

import {api, LightningElement} from 'lwc';

export default class ModelWindow extends LightningElement {

    @api
    cancelLabel;

    @api
    successLabel;

    @api
    pageTitle;

    @api
    pageBody = 'Default body';

    get isFooterVisible(){
        return this.cancelLabel !== undefined || this.successLabel !== undefined;
    }

    handleClick(event) {
        const pressedButtonLabel = event.target.label;

        const pageNumberEvent = new CustomEvent(
            "buttonPressed",
            { detail : { pressedButtonLabel }}
        )
        this.dispatchEvent(pageNumberEvent);
    }
}