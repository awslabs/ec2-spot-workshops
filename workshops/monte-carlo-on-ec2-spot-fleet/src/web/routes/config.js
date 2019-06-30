var express = require('express');
var router = express.Router();

// Require controller modules
var config_controller = require('../controllers/ConfigController');

/* GET users listing. */
router.get('/', config_controller.config);


/* GET home page. */
router.post('/', config_controller.config_lab);


module.exports = router;
