const express = require("express");
const connectionController = require("../controllers/connection-controller.js");

const router = express.Router();

router.route('/')
    .all(connectionController.connectDB);

module.exports = router;
