const functions = require("firebase-functions");

const stripe = require('stripe')('sk_test_51LGj6tFS2FZdmPkQC27Hciu45hp1UdzyvPJZ9KNJBmeAOfxuuZh7YEmbyf1lmtzUbw8DuNHt2myibSVkcsgFuHUJ00K9VcbjnB');

exports.StripePaymentIntent = functions.https.onRequest(async(req, res) =>{
    let customerId;

    const customerList = await stripe.customers.list({
        email: req.body.email,
        limit: 1,
    });

    if (customerList.data.length !== 0){
        customerId = customerList.data[0].id;
    }else{
        const customer = await stripe.customers.create({
            email: req.body.email
        });
        customerId = customer.data.id;
    }
    const ephemeralKey = await stripe.ephemeralKeys.create(
      {customer: customerId},
      {apiVersion: '2023-10-16'}
    );
    const paymentIntent = await stripe.paymentIntents.create({
      customer: customerId,
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
                currency: 'eur',
                ephemeralKey: ephemeralKey.secret,
                customer: customerId,
                publishableKey: 'pk_live_51LGj6tFS2FZdmPkQGJFMKJhYLRgbMhrk63FZG7uzOWPolmJbl1OHsrqFkzQYgEu4XuwDoZBwTrxsmkMxHWbxxFQx00xnTzyn8u'
            });
        }
    });
});


exports.StripeIdentity = functions.https.onRequest(async (req, res) => {
    try {
        const verificationSession = await stripe.identity.verificationSessions.create({
            type: 'document',
            options: {
                document: {
                    allowed_types: ['passport','driving_license'],
                    require_live_capture: true,
                    require_matching_selfie: true,
                }
            }
        });

        res.json({
            id: verificationSession.id,
            url: verificationSession.url
        });
    } catch (error) {
        console.error("Error creating verification session:", error);
        res.status(500).json({
            error: "Error creating verification session",
        });
    }
});



