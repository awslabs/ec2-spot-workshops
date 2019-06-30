var fs = require('fs');

exports.config = function(req, res) {

    try {
       // Pull existing Config
        var labConfig = JSON.parse(fs.readFileSync('./labConfig.json', 'utf8'));
        var awsConfig = JSON.parse(fs.readFileSync('./config.json', 'utf8'));
        res.render('config', { title: 'Configuration Page - Spot Stock Trading Lab', sqs: labConfig.sqs, s3: labConfig.s3, awsRegion: awsConfig.region });
    }
    catch(ex){
        res.render('config', { title: 'Configuration Page - Spot Stock Trading Lab', sqs: '', s3: '', awsRegion: '' });
    }
};

exports.config_lab = function(req, res) {

    var sqsUrl = req.body.sqs
    var s3Bucket = req.body.bucket
    var awsRegion = req.body.region

    fs.writeFile("./labConfig.json", "{ \"sqs\": \""+ sqsUrl +"\", \"s3\": \""+ s3Bucket +"\"}", function(err) {
        var feedback = Array();
        if(err) {
            feedback.push(err.message);
            res.render('config', { title: 'Configuration Page - Spot Stock Trading Lab - Error', feedback: feedback, sqs: sqsUrl, s3: s3Bucket, awsRegion: awsRegion });
        }
    });

    fs.writeFile("./config.json", "{ \"region\": \""+ awsRegion +"\"}", function(err) {
        var feedback = Array();
        if(err) {
            feedback.push(err.message);
            res.render('config', { title: 'Configuration Page - Spot Stock Trading Lab - Error', feedback: feedback, sqs: sqsUrl, s3: s3Bucket, awsRegion: awsRegion });
        }
        feedback.push('Config was saved!');
        res.render('config', { title: 'Configuration Page - Spot Stock Trading Lab - Saved', feedback: feedback, sqs: sqsUrl, s3: s3Bucket, awsRegion: awsRegion });
    });


}