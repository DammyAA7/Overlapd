const functions = require("firebase-functions");
const stripe = require('stripe')('sk_test_51OWmrwIaruu0MDtuTh7GPThpzMdCA8h1Fldtd5HVnS5nPyjUdmUYuMV5kf7gQGNV1FwWMo1DCdFHo3lt45c1UjYv00vqvpo7zr');
admin.initializeApp();

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
      transfer_data:{
        amount: 599,
        destination: 'acct_1OYD9AIejXw0Dd0j'
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
            },
            metadata:{
                uid: req.body.uid
            }
        });

        res.json({
            id: verificationSession.id,
            url: verificationSession.url,
            status: verificationSession.status
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
            business_profile:{
                mcc: '4215',
                product_description: 'Deliver items to client on deliverers existing route'
            },
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

exports.stripeWebhook = functions.https.onRequest(async (request, response) => {
      try {
        let event;
        try {
          event = stripe.webhooks.constructEvent(
              request.rawBody,
              request.headers["stripe-signature"],
              "whsec_6f2773184596d291d5405f597ba7bcb3453a9ffbe335e8a9be1d45b209b28ec1",
          );
        } catch (error) {
          functions.logger.info("stripe webhook verification error",
              error);
          return response.sendStatus(400);
        }
        switch (event.type) {
            case 'identity.verification_session.created':
              const {uid} = request.body.data.object.metadata;
              await _updateStatus(uid);
              break;
            case 'identity.verification_session.processing':
              const identityVerificationSessionProcessing = event.data.object;
              // Then define and call a function to handle the event identity.verification_session.processing
              break;
            case 'identity.verification_session.requires_input':
              const identityVerificationSessionRequiresInput = event.data.object;
              // Then define and call a function to handle the event identity.verification_session.requires_input
              break;
            case 'identity.verification_session.verified':
              const identityVerificationSessionVerified = event.data.object;
              // Then define and call a function to handle the event identity.verification_session.verified
              break;
            // ... handle other event types
            default:
              console.log(`Unhandled event type ${event.type}`);
          }
        if (event.type === "payment_intent.succeeded") {
          const {customerId, productId} = request.body.data.object.metadata;
          await _savePurchase(customerId, productId);
        }
        return response.sendStatus(200);
      } catch (error) {
        functions.logger.error("stripe webhook error", error);
        return response.sendStatus(400);
      }
    });


async function _savePurchase(customerId, productId) {
  const product = await _getProduct(productId);
  await admin
      .firestore()
      .collection("purchases").add({
        customerId,
        product,
        datePurchased: admin.firestore.FieldValue.serverTimestamp(),
      });
}

