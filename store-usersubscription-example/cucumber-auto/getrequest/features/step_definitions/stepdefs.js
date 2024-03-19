const { Given, When, Then, setDefaultTimeout } = require('@cucumber/cucumber');
const axios = require('axios');
const pactum = require('pactum');
const assert = require('assert').strict;

let apiEndpoint;
let response;

setDefaultTimeout(60 * 1000);

Given('I set GET service api endpoint', function () {
  apiEndpoint = 'http://localhost:8090/registered';
});

Then('send a GET HTTP request', {timeout: 120 * 1000}, async function () {
    response = await axios.get(apiEndpoint);
});

Then('check if the list of subscribers is not empty', async function () {
  console.log(response);
  if (typeof response == 'undefined') {
    throw new Error("List of subscribers is empty.");
  }
});
