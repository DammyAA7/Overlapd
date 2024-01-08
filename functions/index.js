const functions = require("firebase-functions");

const stripe = require('stripe')('pk_test_51LGj6tFS2FZdmPkQgjFVjTFGhSMxHdPkWHHT4SKRXODBZ5YUovBqZsrNLh4LlF4NAgSYTd5viwuqgOOXBLtEewym00Z2Xl2VbQ');

exports.StripePaymentIntent = functions.https.onRequest(async(req, res) =>{
    const paymentIntent = await stripe.paymentIntents.create({
      amount: 2000,
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
                amount: 2000,
                currency: 'eur'
            });
        }
    });
});

