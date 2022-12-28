/**
 * Created by evgeny on 26.12.2022.
 */

import {LightningElement, wire, track, api} from 'lwc';
import getExchangeRates from '@salesforce/apex/SalaryTable_Controller.getExchangeRates';
import getCurrentUserSalary from '@salesforce/apex/SalaryTable_Controller.getCurrentUserSalary';
import updateExchangeRates from '@salesforce/apex/SalaryTable_Controller.updateExchangeRates';
import fetchUserSessionId from '@salesforce/apex/SalaryTable_Controller.fetchUserSessionId';

const DATA_LABELS = {
    IsoCode: 'IsoCode',
    ConversionRate: 'ConversionRate'
}

const COLUMNS = [
    {
        label: 'Currency',
        fieldName: DATA_LABELS.IsoCode,
        type: 'text'
    },
    {
        label: 'Salary',
        fieldName: DATA_LABELS.ConversionRate,
        type: 'number'
    },
];

const LABELS = {
    cardHeaderTitle: 'Salary',
    buttonUpdateRates: 'Update exchange rates'
};

export default class SalaryTable extends LightningElement {
    labels = LABELS;
    columns = COLUMNS;
    viewData;
    salary;

    async connectedCallback() {
        await this.fillRatesTable();
    }

    async fillRatesTable() {
        this.salary = await getCurrentUserSalary();
        const response = await getExchangeRates();
        this.viewData = [];
        response.forEach(exchangeRate => {
            let currencyCode = exchangeRate[DATA_LABELS.IsoCode];
            let conversionRate = this.salary*exchangeRate[DATA_LABELS.ConversionRate];
            console.log(exchangeRate[DATA_LABELS.ConversionRate], this.salary)

            let packed = {IsoCode: currencyCode, ConversionRate: conversionRate};
            this.viewData.push(packed);
        })
    }

    async handleClick(event){
        const sessionId = await fetchUserSessionId();
        await updateExchangeRates({sessionId: sessionId}).then(result=>{
            console.log(result);
        }).catch(error=>{
            console.log(error);
        })
        await this.fillRatesTable();
    }
}