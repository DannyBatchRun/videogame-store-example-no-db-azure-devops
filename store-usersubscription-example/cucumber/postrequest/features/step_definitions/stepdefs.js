const { Given, When, Then, setDefaultTimeout } = require('@cucumber/cucumber');
const axios = require('axios');
const pactum = require('pactum');
const assert = require('assert').strict;

let apiEndpoint;
let requestBody;
let response;

setDefaultTimeout(60 * 1000);

Given('I set POST service api endpoint', function () {
  apiEndpoint = 'http://localhost:8090/add/monthlysubscription';
});

When('set request BODY with following details:', function (dataTable) {
  requestBody = dataTable.rowsHash();
});

Then('send a POST HTTP request', {timeout: 120 * 1000}, async function () {
  response = await axios.post(apiEndpoint, requestBody);
});
