const functions = require("firebase-functions");

const stripe = require('stripe')('sk_test_51OWmrwIaruu0MDtuTh7GPThpzMdCA8h1Fldtd5HVnS5nPyjUdmUYuMV5kf7gQGNV1FwWMo1DCdFHo3lt45c1UjYv00vqvpo7zr');

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
      amount: parseInt(req.body.amount) + 599,
      currency: 'eur',
      capture_method: 'manual',
      automatic_payment_methods: {
        enabled: true,
      },
      application_fee_amount: 599,
      transfer_data:{
        destination: 'acct_1OXtFrI6RzzbHE2P'
      }
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
                publishableKey: 'pk_test_51OWmrwIaruu0MDtu9f0fOLYUdaDsxU6FHsV2TtXLw6CstWMCKPwZhhldZEWSmsStYYTYpfeRfzGVAZ9tfLKODOYt00gDUZP4EI'
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


exports.StripeCreateConnectAccount = functions.https.onRequest(async (req, res) => {
    try {
        const account = await stripe.accounts.create({
            type: 'express',
            business_type: 'individual',
            country: 'IE',
            email: req.body.email,
            capabilities: {
                card_payments: {
                    requested: true,
                },
                transfers: {
                    requested: true,
                },
            },
            default_currency: 'eur',
            metadata: {
                email : req.body.email,
                uid: req.body.uid,
            }
        });

        res.json({
            id: account.id,
        });
    } catch (error) {
        console.error("Error creating account session:", error);
        res.status(500).json({
            error: "Error creating account session",
        });
    }
});


exports.StripeCreateAccountLink = functions.https.onRequest(async (req, res) => {
    try {
        const accountLink = await stripe.accountLinks.create({
            account: req.body.account,
            type: 'account_onboarding',
            refresh_url:'https://google.com',
            return_url:'https://google.com',
        });

        res.json({
            url: accountLink.url,
        });
    } catch (error) {
        console.error("Error creating account link session:", error);
        res.status(500).json({
            error: "Error creating account link session",
        });
    }
});



