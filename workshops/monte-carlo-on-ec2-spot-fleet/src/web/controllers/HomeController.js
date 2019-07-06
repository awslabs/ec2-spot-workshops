var AWS = require('aws-sdk');
var fs = require('fs');

exports.index = function(req, res) {
    res.render('index', { title: 'lab3: Spot Stock Trading Lab' });
};


exports.run_trade = function(req, res) {
    //res.send('Not implemented: you tried to run the spot trade');
    req.checkBody('stock', 'Stock Symbol is required and can not be null').notEmpty();
    req.checkBody('short', 'Short Window is required and can not be null').notEmpty();
    req.checkBody('short', 'Short Window must be an integer').isInt();
    req.checkBody('long', 'Long Window is required and can not be null').notEmpty();
    req.checkBody('long', 'Long Window must be an integer').isInt();
    req.checkBody('days', 'Days is required and can not be null').notEmpty();
    req.checkBody('days', 'Days must be an integer').isInt();
    req.checkBody('iter', 'Iterations is required and can not be null').notEmpty();
    req.checkBody('iter', 'Iterations must be an integer').isInt();
    //Run the validators
    var errors = req.validationErrors();

    if (errors) {
        //If there are errors render the form again, passing the previously entered values and errors
        res.render('index', { title: 'lab3: Spot Stock Trading Lab - validation failed', errors: errors, stock:req.body.stock, short:req.body.short, long:req.body.long, days:req.body.days, iter:req.body.iter});
        return;
    }
    else {

        var labConfig = JSON.parse(fs.readFileSync('./labConfig.json', 'utf8'));

        var SQS = new AWS.SQS();

        AWS.config.loadFromPath('./config.json');



        // Create an SQS service object
        var sqs = new AWS.SQS({apiVersion: '2012-11-05'});
        var curTime = new Date();
        var milsTime = curTime.getTime();
        var params = {
            DelaySeconds: 10,
            MessageAttributes: {
                "stock": {
                    DataType: "String",
                    StringValue: req.body.stock
                },
                "short": {
                    DataType: "Number",
                    StringValue: req.body.short
                },
                "long": {
                    DataType: "Number",
                    StringValue: req.body.long
                },
                "days": {
                    DataType: "Number",
                    StringValue: req.body.days
                },
                "iter": {
                    DataType: "Number",
                    StringValue: req.body.iter
                },
                "key": {
                    DataType: "Number",
                    StringValue: milsTime.toString()
                },
                "bucket": {
                    DataType: "String",
                    StringValue: labConfig.s3
                }
            },
            MessageBody: "Spot lab",
            QueueUrl: labConfig.sqs
        };

        if(req.body.isPreview != "on") {
            sqs.sendMessage(params, function (err, data) {
                if (err) {
                    var errors = new Array();
                    errors.push(err);
                    res.render('index', {
                        title: 'lab3: Spot Stock Trading Lab - validation failed',
                        errors: errors
                    });
                    return;
                } else {
                    res.render('index', {
                        title: 'lab3: Spot Stock Trading Lab - validation failed',
                        sqs: 'Trade Strategy Executing'
                    });
                    return;
                }
            });
        }
        else {
            res.render('index', {
                title: 'lab3: Spot Stock Trading Lab - Preview Response',
                previewParams: params
            });
        }
    }
};