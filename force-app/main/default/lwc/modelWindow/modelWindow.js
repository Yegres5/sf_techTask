/**
 * Created by evgeny on 31.01.2023.
 */

import {api, LightningElement} from 'lwc';

export default class ModelWindow extends LightningElement {

    @api
    showCloseButton = false;

    @api
    setTitleStyle(titleStyle) {
        for (const [property, value] of Object.entries(titleStyle)) {
            this.applyCSS(this.title, property, value);
        }
    }

    get title() {
        return this.template.querySelector('slot[name="title"]');
    }

    applyCSS(element, property, value) {
        if (element) {
            element.style[property] = value;
        }
    }

    handleClick(event) {
        this.dispatchEvent(new CustomEvent("close", { target : event.target }));
    }
}