/**
 * Created by Evgenii Sazhnev on 02.03.2023.
 */

import {LightningElement} from 'lwc';

export default class ParentModelWindow extends LightningElement {
    showModelWindow = false;

    handleClick(event) {
        switch (event?.target?.label) {
            case 'changeCSS': {
                this.template.querySelector('c-model-window').setTitleStyle({ 'color' : 'blue' });
                break;
            }

            default:
                this.showModelWindow = !this.showModelWindow;
        }
    }

}