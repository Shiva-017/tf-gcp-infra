const request = require("supertest");
const app = require("../app.js");
const { describe, expect } = require("@jest/globals");
const User = require("../models/user.js");

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

describe("Integration Tests for User Operations", () => {
    let username;
    let password;

    beforeAll(async () => {
        // Ensure database tables are created before running tests
        await User.sync();
    });

    it("creates a new user and checks if the user is created", async () => {
        try {
            const newUser = {
                firstname: "alpha",
                lastname: "user",
                username: "test1001@example.com",
                password: "password123"
            };

            const response = await request(app)
                .post("/v1/user/self")
                .send(newUser)
                .expect(201);

            expect(response.body).toHaveProperty("id");
            username = response.body.username;
            password = "password123";

            // Check if the created user can be retrieved with Basic auth headers
            const getUserResponse = await request(app)
                .get(`/v1/user/self`)
                .set("Authorization", `Basic ${Buffer.from(`${username}:${password}`).toString("base64")}`)
                .expect(200);

            expect(getUserResponse.body.username).toEqual(username);
        } catch (err) {
            expect(false).toBe(true);
        }
    });

    it("updates an existing user and checks if it's updated", async () => {
        try {
            const updatedUserInfo = {
                firstname: "beta",
                lastname: "user",
                password: "updatedpassword"
            };
            const response = await request(app)
                .put(`/v1/user/self`)
                .set("Authorization", `Basic ${Buffer.from(`${username}:${password}`).toString("base64")}`)
                .send(updatedUserInfo)
                .expect(204);

            // Check if the updated user information can be retrieved
            const getUserResponse = await request(app)
                .get(`/v1/user/self`)
                .set("Authorization", `Basic ${Buffer.from(`${username}:${updatedUserInfo.password}`).toString("base64")}`)
                .expect(200);
            expect(getUserResponse.body.first_name).toEqual(updatedUserInfo.firstname);
        } catch (err) {
            expect(false).toBe(true);
        }
    });

    afterAll(async () => {
        // Remove the user model
        await User.destroy({ where: { username } });

        await User.sequelize.close();
    });
});
