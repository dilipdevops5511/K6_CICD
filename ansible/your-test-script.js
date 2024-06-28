import http from 'k6/http';
import { check, sleep } from 'k6';
import { SharedArray } from 'k6/data';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';

export let options = {
  scenarios: {
    contacts: {
      executor: 'shared-iterations',
      vus: 10,
      iterations: 5,
      maxDuration: '10s',
    },
  },
};

// Using SharedArray to load and parse the CSV file only once
const csvData = new SharedArray('csvData', function () {
  return papaparse.parse(open('./combined.csv'), { header: true }).data;
});

export default function () {
  // GET request
  const urlGet = 'https://lt-1-stage-api.penpencil.co/v1/conversation/65e4d37af8dc041a31e55007/chat?limit=50';
  const headersGet = {
    'Content-Type': 'application/json',
    'Accept': 'application/json, text/plain, */*',
    'Referer': 'https://admin-v2-stage.penpencil.co/',
    'Client-Type': 'ADMIN',
    'Authorization': `Bearer ${csvData[__VU - 1]['token']}`,
  };

  const resGet = http.get(urlGet, { headers: headersGet });
  check(resGet, { 'status is 200': (r) => r.status === 200 });

  console.log(`GET Response for VU ${__VU} - Iteration ${__ITER}:`);
  console.log(`Status Code: ${resGet.status}`);
  console.log('Response Body:');
  console.log(JSON.stringify(resGet.body, null, 2));

  // Add a sleep to simulate user activity
  sleep(1);
}
