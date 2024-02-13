const express = require("express");
const userController = require("../controllers/user-controller.js");

const router = express.Router();

router.route('/')
    .post(userController.createUser)
    .get(userController.getUser)
    .put(userController.updateUserInfo);

module.exports = router;
