import http from 'k6/http';
import { check, sleep } from 'k6';
import { SharedArray } from 'k6/data';
import papaparse from 'https://jslib.k6.io/papaparse/5.1.1/index.js';
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.1/index.js';
import { htmlReport } from "https://raw.githubusercontent.com/benc-uk/k6-reporter/main/dist/bundle.js";

export let options = {
  scenarios: {
    contacts: {
      executor: 'shared-iterations',
      vus: 1,
      iterations: 5,
      maxDuration: '10s',
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests must complete below 500ms
  },
  summaryTrendStats: ['avg', 'p(95)', 'max'], // Stats to show in the summary output
};

// Using SharedArray to load and parse the CSV file only once
const csvData = new SharedArray('csvData', function () {
  return papaparse.parse(open('./data_part1.csv'), { header: true }).data;
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

  // Perform GET request and capture response
  const resGet = http.get(urlGet, { headers: headersGet });
  check(resGet, { 'status is 200': (r) => r.status === 200 });

  // Log response details
  console.log(`GET Response for VU ${__VU} - Iteration ${__ITER}:`);
  console.log(`Status Code: ${resGet.status}`);
  console.log('Response Body:');
  console.log(JSON.stringify(resGet.body, null, 2));

  // Write response body to a JSON file
  const jsonFilePath = `/home/ubuntu/output_${__VU}_${__ITER}.json`;
  const responseJSON = JSON.parse(resGet.body);
  const jsonContent = JSON.stringify(responseJSON, null, 2);

  const file = open(jsonFilePath, 'w');
  file.write(jsonContent);
  file.close();

  // Add a sleep to simulate user activity
  sleep(1);
}

// Handle summary function for generating HTML report
export function handleSummary(data) {
  return {
    "summary.html": htmlReport(data),
  };
}
