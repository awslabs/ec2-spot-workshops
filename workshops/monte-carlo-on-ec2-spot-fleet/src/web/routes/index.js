var express = require('express');
var router = express.Router();

// Require controller modules
var home_controller = require('../controllers/HomeController');

/* GET home page. */
router.get('/', home_controller.index);

/* GET home page. */
router.post('/', home_controller.run_trade);

// router.get('/', function(req, res, next) {
//   res.render('index', { title: 'Landing Page - Spot Stock Trading Lab' });
// });


module.exports = router;
