const request = require("supertest");
const app = require("../app.js");
const { describe, expect } = require("@jest/globals");

describe("Integration Test for GET/healthz", () => {

    it("Database connection successful.", async () => {
        let status = true;

        try {
            const response = await request(app).get("/healthz");
            expect(response.status).toBe(200);
        } catch (err) {
            status = false;
            expect(status).toBe(true);
        }
    });
});
