const { Given, When, Then, setDefaultTimeout } = require('@cucumber/cucumber');
const axios = require('axios');
const pactum = require('pactum');
const assert = require('assert').strict;

let apiEndpoint;
let response;

setDefaultTimeout(60 * 1000);

Given('I set GET service api endpoint', function () {
  apiEndpoint = 'http://localhost:8080/allcarts';
});

Then('send a GET HTTP request', {timeout: 120 * 1000}, async function () {
    response = await axios.get(apiEndpoint);
    console.log(response);
});
