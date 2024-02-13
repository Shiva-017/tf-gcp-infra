const { setErrorResponse, setUserAPIResponse, setUserAPIResponseWithData } = require("./response-handler.js");
const { register, fetchUser, updateUser } = require("../services/user-service.js");
const { isEmail } = require('../helpers/email-validation.js');

exports.createUser = async (req, res) => {
    try {
        const user = req.body;
        if (!user || Object.keys(user).length === 0 || user.username === undefined || user.password === undefined) {
            res.status(400).send();
        } else {
            if (!isEmail(user.username)) {
                res.status(400).send();
            }
            const existingUser = await fetchUser(user.username, user.password);
            if (existingUser.success) {
                res.status(400).send();
            }
            const newUser = await register(user);
            const data = { ...newUser.toJSON() };
            delete data.password;
            setUserAPIResponseWithData(data, req, res, 201);
        }
    }
    catch (err) {
        setErrorResponse(err, res);
    }
};

exports.getUser = async (req, res) => {
    try {
        if (req.headers.authorization && req.headers.authorization.startsWith('Basic ')) {
            const base64Credentials = req.headers.authorization.split(' ')[1];
            const credentials = Buffer.from(base64Credentials, 'base64').toString('ascii');
            const [username, password] = credentials.split(':');
            const userDetails = await fetchUser(username, password);
            if (userDetails.success) {
                const userInfo = { ...userDetails.user.toJSON() };
                delete userInfo.password;
                setUserAPIResponseWithData(userInfo, req, res, 200);
            } else {
                res.status(401).send();
            }
        } else {
            res.status(401).send();
        }
    }
    catch (err) {
        setErrorResponse(err, res);
    }
};

exports.updateUserInfo = async (req, res) => {
    try {
        const updateInfo = req.body;
        const updateOnly = ['firstname', 'lastname', 'password'];
        if (!updateInfo || Object.keys(updateInfo).length === 0 || Object.keys(updateInfo).some(key => !updateOnly.includes(key))) {
            res.status(400).send();
        } else {
            if (req.headers.authorization && req.headers.authorization.startsWith('Basic ')) {
                const base64Credentials = req.headers.authorization.split(' ')[1];
                const credentials = Buffer.from(base64Credentials, 'base64').toString('ascii');
                const [username, password] = credentials.split(':');
                const updateResponse = await updateUser(username, password, updateInfo);
                setUserAPIResponse(req, res, updateResponse.status);
            } else {
                res.status(401).send();
            }
        }
    }
    catch (err) {
        setErrorResponse(err, res);
    }
};
