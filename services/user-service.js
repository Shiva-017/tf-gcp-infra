const User = require("../models/user.js");
const bcrypt = require('bcrypt');

// function to fetch the user chat
exports.register = async (user) => {
    const { firstname, lastname, username, password } = user;
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    const newUser = await User.create({
        first_name: firstname,
        last_name: lastname,
        username,
        password: hashedPassword
    });
    return newUser;
};

exports.fetchUser = async (username, password) => {
    const user = await User.findOne({ where: { username } });
    if (user) {
        const passwordMatched = await bcrypt.compare(password, user.password);
        if (passwordMatched) {
            return { success: true, user };
        } else {
            return { success: false, message: 'Incorrect password' };
        }
    } else {
        return { success: false, message: 'User not found' };
    }
};

exports.updateUser = async (username, oldPassword, userDetails) => {
    const { firstname, lastname, password } = userDetails;
    const user = await User.findOne({ where: { username } });
    if (user) {
        const passwordMatched = await bcrypt.compare(oldPassword, user.password);
        if (passwordMatched) {
            const saltRounds = 10;
            const hashedPassword = await bcrypt.hash(password, saltRounds);
            await User.update({ first_name: firstname, last_name: lastname, password: hashedPassword, account_updated: Date.now() }, { where: { username } });
            return { status: 204 };
        } else {
            return { status: 401 };
        }
    } else {
        return { status: 404 };
    }
};
