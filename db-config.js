const { config } = require('dotenv');

config();
exports.databaseConfig = {
    dialect: 'mysql',
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    pool: {
        max: 5,
        min: 0,
        acquire: 3000,
        idle: 1000,
    },
};
