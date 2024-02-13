const { DataTypes, Sequelize } = require('sequelize');
const { databaseConfig } = require('./db-config.js');
const { config } = require('dotenv');

config();
const db = process.env.DB_NAME;
const user = process.env.DB_USER;
const password = process.env.DB_PASSWORD;
const sequelize = new Sequelize(db, user, password, databaseConfig, {
    define: {
        hooks: {
            beforeUpdate(user) {
                user.account_updated = DataTypes.NOW();
            }
        }
    }
});

module.exports = sequelize;
