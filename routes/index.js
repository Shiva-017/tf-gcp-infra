const connectionRouter = require('./connection-route.js');
const userRouter = require('./user-route.js');
const { handleRouteResponse } = require('../controllers/response-handler.js');

module.exports = (app) => {
    // app.use(handleRouteResponse);
    app.use('/healthz', connectionRouter);
    app.use('/v1/user/self', userRouter);
};
