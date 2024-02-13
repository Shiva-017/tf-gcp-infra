const sequelize = require("../db-connection.js");
const { setResponse, setErrorResponse } = require("./response-handler.js");

exports.connectDB = async (req, res) => {
    try {
        await sequelize.authenticate();
        setResponse(req, res);
    }
    catch (err) {
        setErrorResponse(err, res);
    }
}
