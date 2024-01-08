const functions = require("firebase-functions");

const stripe = require('stripe')('sk_test_51LGj6tFS2FZdmPkQC27Hciu45hp1UdzyvPJZ9KNJBmeAOfxuuZh7YEmbyf1lmtzUbw8DuNHt2myibSVkcsgFuHUJ00K9VcbjnB');

exports.StripePaymentIntent = functions.https.onRequest(async(req, res) =>{
    const paymentIntent = await stripe.paymentIntents.create({
      amount: parseInt(req.body.amount),
      currency: 'eur',
      capture_method: 'manual',
      automatic_payment_methods: {
        enabled: true,
      },
    }, function (error, paymentIntent){
        if(error !=null){
            res.json({"error":error});
        }else{
            res.json({
                paymentIntent: paymentIntent.client_secret,
                paymentIntentData: paymentIntent,
                amount: req.body.amount,
                currency: 'eur'
            });
        }
    });
});

