import 'dotenv/config';
import http from 'http';

// We will launch the server on an ephemeral port, run all tests, then shut down.
const PORT = 5055;
process.env.PORT = String(PORT);

const makeRequest = (path, options = {}) => {
  return new Promise((resolve, reject) => {
    const reqOptions = {
      hostname: '127.0.0.1',
      port: PORT,
      path,
      method: options.method || 'GET',
      headers: {
        'Content-Type': 'application/json',
        ...(options.headers || {})
      }
    };

    const req = http.request(reqOptions, (res) => {
      let body = '';
      res.on('data', (chunk) => body += chunk);
      res.on('end', () => {
        let json = null;
        try {
          json = JSON.parse(body);
        } catch {
          json = body;
        }
        resolve({ status: res.statusCode, headers: res.headers, body: json });
      });
    });

    req.on('error', reject);
    if (options.body) {
      req.write(typeof options.body === 'string' ? options.body : JSON.stringify(options.body));
    }
    req.end();
  });
};

const runTests = async () => {
  console.log('--- Starting Phase 1 Automated Verification Suite ---');
  let passed = 0;
  let failed = 0;

  const assert = (condition, message) => {
    if (condition) {
      console.log(`  [PASS] ${message}`);
      passed++;
    } else {
      console.error(`  [FAIL] ${message}`);
      failed++;
    }
  };

  try {
    // 1. Status Check
    const statusRes = await makeRequest('/status');
    assert(statusRes.status === 200 && statusRes.body.status === 'online', 'GET /status returns 200 online');

    // 2. Unauthenticated POST /api/menu blocked
    const unauthMenu = await makeRequest('/api/menu', { method: 'POST', body: { name: 'Test' } });
    assert(unauthMenu.status === 401, 'POST /api/menu without token returns 401 Unauthorized');

    // 3. Unauthenticated GET /api/demo-bookings blocked
    const unauthBookings = await makeRequest('/api/demo-bookings');
    assert(unauthBookings.status === 401, 'GET /api/demo-bookings without token returns 401 Unauthorized');

    // 4. Unauthenticated GET /api/enquiries blocked
    const unauthEnquiries = await makeRequest('/api/enquiries');
    assert(unauthEnquiries.status === 401, 'GET /api/enquiries without token returns 401 Unauthorized');

    // 5. Registration input validation
    const badEmailReg = await makeRequest('/api/auth/register', {
      method: 'POST',
      body: { name: 'Test User', email: 'not-an-email', password: 'password123' }
    });
    assert(badEmailReg.status === 400, 'Registration with invalid email format returns 400');

    const shortPassReg = await makeRequest('/api/auth/register', {
      method: 'POST',
      body: { name: 'Test User', email: 'valid@example.com', password: '123' }
    });
    assert(shortPassReg.status === 400, 'Registration with short password (<6) returns 400');

    const invalidRoleReg = await makeRequest('/api/auth/register', {
      method: 'POST',
      body: { name: 'Test User', email: 'valid@example.com', password: 'password123', role: 'SUPERUSER' }
    });
    assert(invalidRoleReg.status === 400, 'Registration with unwhitelisted role returns 400');

    // 6. Valid Registration (Owner)
    const testOwnerEmail = `owner_${Date.now()}@testcafe.com`;
    const regRes = await makeRequest('/api/auth/register', {
      method: 'POST',
      body: { name: 'Owner Test', email: testOwnerEmail, password: 'securePassword123', role: 'OWNER' }
    });
    assert(regRes.status === 201 && regRes.body.token, 'Registration with valid OWNER returns 201 and token');
    const ownerToken = regRes.body.token;

    // 7. Duplicate Registration Conflict
    const dupReg = await makeRequest('/api/auth/register', {
      method: 'POST',
      body: { name: 'Owner Duplicate', email: testOwnerEmail, password: 'securePassword123' }
    });
    assert(dupReg.status === 409, 'Duplicate registration returns 409 Conflict');

    // 8. Login verification
    const badLogin = await makeRequest('/api/auth/login', {
      method: 'POST',
      body: { email: testOwnerEmail, password: 'wrongPassword' }
    });
    assert(badLogin.status === 401, 'Login with wrong password returns 401 Unauthorized');

    const goodLogin = await makeRequest('/api/auth/login', {
      method: 'POST',
      body: { email: testOwnerEmail, password: 'securePassword123' }
    });
    assert(goodLogin.status === 200 && goodLogin.body.token, 'Login with valid credentials returns 200 and token');

    // 9. Customer registration & RBAC test
    const testCustEmail = `cust_${Date.now()}@customer.com`;
    const custReg = await makeRequest('/api/auth/register', {
      method: 'POST',
      body: { name: 'Customer Test', email: testCustEmail, password: 'securePassword123', role: 'CUSTOMER' }
    });
    const custToken = custReg.body.token;

    const custMenuPost = await makeRequest('/api/menu', {
      method: 'POST',
      headers: { Authorization: `Bearer ${custToken}` },
      body: { badge: 'NEW', category: 'SNACKS', name: 'Item', description: 'Desc', image: 'https://example.com/img.jpg', price: 10 }
    });
    assert(custMenuPost.status === 403, 'POST /api/menu with CUSTOMER token returns 403 Forbidden');

    const custBookingsGet = await makeRequest('/api/demo-bookings', {
      headers: { Authorization: `Bearer ${custToken}` }
    });
    assert(custBookingsGet.status === 403, 'GET /api/demo-bookings with CUSTOMER token returns 403 Forbidden');

    // 10. Menu validation with OWNER token
    const invalidPricePost = await makeRequest('/api/menu', {
      method: 'POST',
      headers: { Authorization: `Bearer ${ownerToken}` },
      body: { badge: 'NEW', category: 'SNACKS', name: 'Item', description: 'Desc', image: 'https://example.com/img.jpg', price: -10 }
    });
    assert(invalidPricePost.status === 400, 'POST /api/menu with negative price returns 400 Bad Request');

    const invalidImagePost = await makeRequest('/api/menu', {
      method: 'POST',
      headers: { Authorization: `Bearer ${ownerToken}` },
      body: { badge: 'NEW', category: 'SNACKS', name: 'Item', description: 'Desc', image: 'ftp://bad-url', price: 20 }
    });
    assert(invalidImagePost.status === 400, 'POST /api/menu with non-HTTP image URL returns 400 Bad Request');

    const validMenuPost = await makeRequest('/api/menu', {
      method: 'POST',
      headers: { Authorization: `Bearer ${ownerToken}` },
      body: { badge: 'SPECIAL', category: 'BEVERAGES', name: 'Security Verification Tea', description: 'A testing brew', image: 'https://images.unsplash.com/sample', price: 35.5 }
    });
    assert(validMenuPost.status === 201 && validMenuPost.body.itemId, 'POST /api/menu with OWNER token and valid data returns 201 Created');

    // 11. Public demo booking & enquiry submissions
    const badPhoneBooking = await makeRequest('/api/demo-bookings', {
      method: 'POST',
      body: { name: 'Test Person', email: 'test@booking.com', restaurant_name: 'Test Cafe', phone: '123' }
    });
    assert(badPhoneBooking.status === 400, 'Demo booking with invalid phone returns 400');

    const validBooking = await makeRequest('/api/demo-bookings', {
      method: 'POST',
      body: { name: 'Test Person', email: 'test@booking.com', restaurant_name: 'Test Cafe', phone: '+91 9876543210', message: 'Looking for POS demo' }
    });
    assert(validBooking.status === 201 && validBooking.body.type === 'DEMO', 'POST /api/demo-bookings returns 201 with type DEMO');

    const validEnquiry = await makeRequest('/api/enquiries', {
      method: 'POST',
      body: { name: 'Catering Lead', email: 'lead@catering.com', restaurant_name: 'Annual Gala', phone: '+91 9876543210', message: 'Party for 200 pax' }
    });
    assert(validEnquiry.status === 201 && validEnquiry.body.type === 'ENQUIRY', 'POST /api/enquiries returns 201 with type ENQUIRY');

    // 12. Owner retrieving separated bookings and enquiries
    const ownerBookings = await makeRequest('/api/demo-bookings', {
      headers: { Authorization: `Bearer ${ownerToken}` }
    });
    assert(ownerBookings.status === 200 && Array.isArray(ownerBookings.body), 'OWNER can retrieve DEMO bookings with 200 OK');

    const ownerEnquiries = await makeRequest('/api/enquiries', {
      headers: { Authorization: `Bearer ${ownerToken}` }
    });
    assert(ownerEnquiries.status === 200 && Array.isArray(ownerEnquiries.body), 'OWNER can retrieve ENQUIRIES with 200 OK');

    // 13. Fallback JSON 404 handler
    const notFoundRes = await makeRequest('/api/non-existent-route-12345');
    assert(notFoundRes.status === 404 && notFoundRes.body && notFoundRes.body.error, '404 handler returns clean JSON error (not HTML)');

  } catch (err) {
    console.error('Fatal error during test run:', err);
    failed++;
  }

  console.log(`\n--- Verification Complete: ${passed} passed, ${failed} failed ---`);
  process.exit(failed > 0 ? 1 : 0);
};

// Start server and run tests
import('./server.js').then(() => {
  setTimeout(runTests, 1000);
});
