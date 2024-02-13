const app = require('./app.js');
const sequelize = require('./db-connection.js');

sequelize.sync().then(() => {
    const port = 3000;
    app.listen(port, () => console.log(`Server listening at port ${port}`));
}).catch(err => {
    console.error('Unable to sync database:', err);
});
